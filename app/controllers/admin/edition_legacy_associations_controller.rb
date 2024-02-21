class Admin::EditionLegacyAssociationsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!

  def update
    @edition.assign_attributes(edition_params)
    if updater.can_perform? && @edition.save_as(current_user)
      updater.perform!
    end
    redirect_to admin_edition_path(@edition), notice: "The associations have been saved"
  end

private

  def updater
    @updater ||= Whitehall.edition_services.draft_updater(@edition)
  end

  def edition_params
    @edition_params ||=
      params.fetch(:edition, {}).permit(*permitted_edition_attributes)
  end

  def permitted_edition_attributes
    [
      :primary_specialist_sector_tag,
      { secondary_specialist_sector_tags: [],
        topic_ids: [] },
    ]
  end

  def find_edition
    edition = Edition.find(params[:edition_id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end
end
