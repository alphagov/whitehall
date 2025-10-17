class Admin::EditionChangeNotesController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!
  def index
    @change_notes = @edition
      .document
      .editions
      .without_not_published
      .where(minor_change: false)
      .select(:id, :major_change_published_at, :change_note)
      .reorder(major_change_published_at: :desc)
  end

  def edit
    # This is the edition the change note was originally set on, not the latest edition
    @edition_to_change = Edition.find(params[:id])
  end

  def update
    edition_to_change = Edition.find(params[:id])
    old_change_note = edition_to_change.change_note

    # rubocop:disable Rails/SkipsModelValidations
    edition_to_change.update_attribute(:change_note, params[:new_change_note])
    # rubocop:enable Rails/SkipsModelValidations

    EditorialRemark.create!(
      edition: edition_to_change,
      body: "Updated change note from #{old_change_note} to #{params[:new_change_note]}",
      author: current_user,
      created_at: Time.zone.now,
      updated_at: Time.zone.now,
    )

    PublishingApiDocumentRepublishingWorker.perform_async(edition_to_change.document.id)

    flash[:notice] = "Change note updated"
    redirect_to(admin_edition_change_notes_path)
  end

  def confirm_destroy
    @edition_to_change = Edition.find(params[:id])
  end

  def destroy
    edition_to_change = Edition.find(params[:id])
    old_change_note = edition_to_change.change_note

    edition_to_change[:minor_change] = true
    edition_to_change.change_note = nil
    edition_to_change.major_change_published_at = edition_to_change.document.editions.where(minor_change: false).where("id < ?", edition_to_change.id).last.try(:major_change_published_at)
    edition_to_change.save!(validate: false)

    EditorialRemark.create!(
      edition: edition_to_change,
      body: "Deleted change note: #{old_change_note}",
      author: current_user,
      created_at: Time.zone.now,
      updated_at: Time.zone.now,
    )

    PublishingApiDocumentRepublishingWorker.perform_async(edition_to_change.document.id)

    flash[:notice] = "Change note deleted"
    redirect_to(admin_edition_change_notes_path)
  end

private

  def enforce_permissions!
    enforce_permission!(:perform_administrative_tasks, @edition)
  end

  def find_edition
    edition = Edition.find(params[:edition_id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end
