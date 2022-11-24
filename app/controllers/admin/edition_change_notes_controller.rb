class Admin::EditionChangeNotesController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!
  layout "design_system"

  def index
    @change_notes = @edition
      .document
      .editions
      .without_not_published
      .where(minor_change: false)
      .select(:id, :major_change_published_at, :change_note)
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
