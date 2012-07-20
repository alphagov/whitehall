class Admin::PreviewController < Admin::BaseController
  before_filter :find_images, only: :preview
  before_filter :find_attachments, only: :preview
  before_filter :find_lead_image, only: :preview

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
end
