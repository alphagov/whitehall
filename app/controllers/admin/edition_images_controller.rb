class Admin::EditionImagesController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!

  def index; end

  def confirm_destroy; end

  def destroy
    filename = image.image_data.carrierwave_image
    image.destroy!
    @edition.update_lead_image if @edition.can_have_custom_lead_image?
    PublishingApiDocumentRepublishingWorker.perform_async(@edition.document_id)

    redirect_to admin_edition_images_path(@edition), notice: "#{filename} has been deleted"
  end

  def update
    if image.update(params.require(:image).permit(:caption, :alt_text))
      PublishingApiDocumentRepublishingWorker.perform_async(@edition.document_id)
      redirect_to admin_edition_images_path(@edition), notice: "#{image.image_data.carrierwave_image} details updated"
    else
      render :edit
    end
  end

  def create
    @new_image = @edition.images.build
    @new_image.build_image_data(image_params["image_data"])

    @new_image.image_data.validate_on_image = @new_image
    # so that auth_bypass_id is discoverable by AssetManagerStorage
    @new_image.image_data.images << @new_image

    if @new_image.save
      @edition.update_lead_image if @edition.can_have_custom_lead_image?
      PublishingApiDocumentRepublishingWorker.perform_async(@edition.document_id)
      redirect_to edit_admin_edition_image_path(@edition, @new_image.id), notice: "#{@new_image.filename} successfully uploaded"
    elsif new_image_needs_cropping?
      image_kind_config = @new_image.image_data.image_kind_config
      @valid_width = image_kind_config.valid_width
      @valid_height = image_kind_config.valid_height
      @data_url = image_data_url
      render :crop
    else
      @new_image.errors.delete(:"image_data.file", :too_large)
      # Remove @new_image from @edition.images array, otherwise the view will render it in the 'Uploaded images' list
      @edition.images.delete(@new_image)
      render :index
    end
  end

  def edit
    image = Image.find(params[:id])
    flash.now.notice = "The image is being processed. Try refreshing the page." unless image&.image_data&.all_asset_variants_uploaded?
  end

private

  def new_image_needs_cropping?
    @new_image.errors.of_kind?(:"image_data.file", :too_large) && @new_image.errors.size == 1
  end

  def image_data_url
    file = @new_image.image_data.file
    image_data = Base64.strict_encode64(file.read)
    "data:#{file.content_type};base64,#{image_data}"
  end

  def image
    @image ||= find_image
  end
  helper_method :image

  def find_image
    @edition.images.find(params[:id]) if params[:id]
  end

  def find_edition
    edition = Edition.includes(images: :image_data).find(params[:edition_id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end

  def enforce_permissions!
    case action_name
    when "index"
      enforce_permission!(:see, @edition)
    when "edit", "update", "destroy", "confirm_destroy", "create"
      enforce_permission!(:update, @edition)
    else
      raise Whitehall::Authority::Errors::InvalidAction, action_name
    end
  end

  def image_params
    params.fetch(:image, {}).permit(image_data: %i[file image_kind])
  end
end
