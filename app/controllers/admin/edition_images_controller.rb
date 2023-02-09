class Admin::EditionImagesController < Admin::BaseController
  before_action :find_edition
  before_action :redirect_unless_user_can_preview_images_update
  before_action :enforce_permissions!
  layout "design_system"

  def index; end

private

  def find_edition
    edition = Edition.find(params[:edition_id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end

  def redirect_unless_user_can_preview_images_update
    redirect_to edit_admin_edition_path(@edition) unless current_user.can_preview_images_update?
  end

  def enforce_permissions!
    case action_name
    when "index"
      enforce_permission!(:see, @edition)
    else
      raise Whitehall::Authority::Errors::InvalidAction, action_name
    end
  end
end
