class Admin::StandardEditionImagesController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!

  def index; end

  def confirm_destroy; end

  def destroy
    filename = image.image_data.carrierwave_image
    image.destroy!
    @edition.update_lead_image if @edition.can_have_custom_lead_image?
    PublishingApiDocumentRepublishingWorker.perform_async(@edition.document_id, false)

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
      PublishingApiDocumentRepublishingWorker.perform_async(@edition.document_id, false)
      redirect_to admin_standard_edition_images_path(@edition), notice: "#{image.image_data.carrierwave_image} details updated"
    else
      render :edit
    end
  end

  def create
    @images = images_params.map { |image| build_image(image) }

    if @images.empty?
      flash.now.alert = "No images selected. Choose a valid JPEG, PNG, SVG or GIF."
    elsif @images.all?(&:valid?)
      @images.each(&:save!)
      PublishingApiDocumentRepublishingWorker.perform_async(@edition.document_id, false)
      flash.now.notice = "Images successfully uploaded"
    else
      # Remove images from @edition.images array, otherwise the view will render it in the 'Uploaded images' list
      @images.each { |image| @edition.images.delete(image) }
    end

    if @images.many? || @images.first.id.nil?
      render :index
    else
      redirect_to edit_admin_standard_edition_image_path(@edition, @images.first.id)
    end
  end

  def build_image(image)
    new_image = @edition.images.build

    new_image.build_image_data(image["image_data"])

    new_image.image_data.validate_on_image = new_image

    # so that auth_bypass_id is discoverable by AssetManagerStorage
    new_image.image_data.images << new_image

    new_image
  end

  def edit
    flash.now.notice = "The image is being processed. Try refreshing the page." unless image&.image_data&.original_uploaded?
  end

private

  def image_url
    return unless image&.image_data&.original_uploaded?

    image_data = image.image_data
    unless image_data.file.cached?
      image_data.file.download! image_data.file.url
    end
    img_data = Base64.strict_encode64(image_data.file.read)

    "data:#{image_data.file.content_type};base64,#{img_data}"
  end
  helper_method :image_url

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
    edition = StandardEdition.includes(images: :image_data).find(params[:standard_edition_id])
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

  def images_params
    params.fetch(:images, []).map { |image| image.permit(image_data: %i[file image_kind]) }
  end

  def image_data_params
    params.fetch(:image, {}).fetch(:image_data, {}).permit(:file, :image_kind, crop_data: %i[x y width height])
  end

  def image_params
    params.fetch(:image, {}).except(:image_data).permit(:caption, image_data: %i[crop_data file image_kind])
  end
end
