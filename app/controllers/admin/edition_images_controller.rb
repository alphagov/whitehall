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
    image.assign_attributes(image_params)

    if image_data_params["crop_data"].present?
      image_data = image.image_data
      new_image_data = ImageData.new
      new_image_data.to_replace_id = image_data.id
      new_image_data.assign_attributes(image_data_params)
      new_image_data.file.download! image_data.file.url
      new_image_data.save!
      image.image_data = new_image_data
    end

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
    flash.now.notice = "The image is being processed. Try refreshing the page." unless image&.image_data&.original_uploaded?
  end

private

  def image_kind_config
    image.image_data.image_kind_config
  end
  helper_method :image_kind_config

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

  def image_data_params
    params.fetch(:image, {}).fetch(:image_data, {}).permit(:file, :image_kind, crop_data: %i[x y width height])
  end

  def image_params
    params.fetch(:image, {}).except(:image_data).permit(:caption, :alt_text, image_data: %i[crop_data file image_kind])
  end
end
