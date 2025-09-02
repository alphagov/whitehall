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
    @valid_width = image_kind_config.valid_width
    @valid_height = image_kind_config.valid_height

    image_params_hash = image_params.to_h

    begin
      if image_params_hash["image_data"]["crop_data"]
        image_params_hash["image_data"]["crop_data"] = JSON.parse(image_params_hash["image_data"]["crop_data"])
      end
    rescue JSON::ParserError
      render :edit, alert: "Error processing crop data, try again"
    end

    image.assign_attributes(image_params_hash.except("image_data"))

    image.image_data.crop_data = image_params_hash["image_data"]["crop_data"]

    image.image_data.validate_on_image = image

    if image.save
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

    @new_image.image_data.images << @new_image

    if @new_image.save
      @edition.update_lead_image if @edition.can_have_custom_lead_image?
      PublishingApiDocumentRepublishingWorker.perform_async(@edition.document_id)
      flash.notice = "#{@new_image.filename} successfully uploaded"
    else
      # Remove @new_image from @edition.images array, otherwise the view will render it in the 'Uploaded images' list
      @edition.images.delete(@new_image)
    end

    render :index
  end

  def edit
    @valid_width = image_kind_config.valid_width
    @valid_height = image_kind_config.valid_height
  end

private

  def image_kind_config
    image.image_data.image_kind_config
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
    params.fetch(:image, {}).permit(:caption, :alt_text, image_data: %i[crop_data file image_kind])
  end
end
