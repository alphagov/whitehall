class Admin::EditionLegacyAssociationsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!

  def edit; end

  def update
    @edition.assign_attributes(edition_params)
    if updater.can_perform? && @edition.save_as(current_user)
      updater.perform!
    end
    redirect_to admin_edition_path(@edition), saved_confirmation_notice
  end

  private

  def saved_confirmation_notice
    { notice: "The associations have been saved" }
  end

  def updater
    @updater ||= Whitehall.edition_services.draft_updater(@edition)
  end

  def edition_params
    @edition_params ||= params.fetch(:edition, {}).permit(*permitted_edition_attributes)
  end

  def permitted_edition_attributes
    [
      :primary_specialist_sector_tag,
      secondary_specialist_sector_tags: [],
      policy_content_ids: [],
      topic_ids: [],
    ]
  end

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end
end
