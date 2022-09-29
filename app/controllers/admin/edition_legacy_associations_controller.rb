class Admin::EditionLegacyAssociationsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!
  before_action :forbid_editing_of_locked_documents
  layout :get_layout

  def edit
    @path = get_path
    render(preview_design_system_user? ? "edit" : "edit_legacy")
  end

  def update
    @edition.assign_attributes(edition_params)
    if updater.can_perform? && @edition.save_as(current_user)
      updater.perform!
    end
    redirect_to get_path, saved_confirmation_notice
  end

private

  def get_layout
    preview_design_system_user? ? "design_system" : "admin"
  end

  def get_path
    paths = {
      "edit" => edit_admin_edition_path(@edition),
      "tags" => edit_admin_edition_tags_path(@edition),
    }
    paths[params[:return]] || admin_edition_path(@edition)
  end

  def saved_confirmation_notice
    { notice: "The associations have been saved" }
  end

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
