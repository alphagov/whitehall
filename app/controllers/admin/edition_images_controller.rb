class Admin::EditionImagesController < Admin::BaseController
  before_action :find_edition
  before_action :redirect_unless_user_can_preview_images_update
  before_action :enforce_permissions!
  layout "design_system"

  def index; end

  def confirm_destroy; end

  def destroy
    filename = image.image_data.carrierwave_image
    image.destroy!
    redirect_to admin_edition_images_path(@edition), notice: "#{filename} has been deleted"
  end

private

  def image
    @image ||= find_image
  end
  helper_method :image

  def find_image
    @edition.images.find(params[:id]) if params[:id]
  end

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
    when "destroy", "confirm_destroy"
      enforce_permission!(:update, @edition)
    else
      raise Whitehall::Authority::Errors::InvalidAction, action_name
    end
  end
end
