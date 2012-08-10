class Admin::PreviewController < Admin::BaseController
  before_filter :find_images, only: :preview
  before_filter :find_attachments, only: :preview
  before_filter :find_lead_image, only: :preview
  before_filter :find_alternative_format_provider, only: :preview

  def preview
    render layout: false
  end

  def find_images
    @images = (params[:image_ids] || []).map { |id| Image.find(id) }
  end

  def find_attachments
    @attachments = (params[:attachment_ids] || []).map { |id| Attachment.find(id) }
  end

  def find_lead_image
    @lead_image = Image.find(params[:lead_image_id]) if params[:lead_image_id]
  end

  def find_alternative_format_provider
    @alternative_format_provider = Organisation.find(params[:alternative_format_provider_id]) if params[:alternative_format_provider_id]
    @alternative_format_contact_email = @alternative_format_provider && @alternative_format_provider.alternative_format_contact_email
  end
end
