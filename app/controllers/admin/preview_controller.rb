class Admin::PreviewController < Admin::BaseController
  before_filter :find_images, only: :preview
  before_filter :find_attachments, only: :preview
  before_filter :limit_access_to_attachments!, only: :preview
  before_filter :find_alternative_format_provider, only: :preview

  def preview
    if Govspeak::HtmlValidator.new(params[:body]).valid?
      render layout: false
    else
      render text: "Content contains possible XSS exploits", status: :forbidden
    end
  end

  def find_images
    @images = (params[:image_ids] || []).map { |id| Image.find(id) }
  end

  def find_attachments
    @attachments = (params[:attachment_ids] || []).map { |id| Attachment.find(id) }
  end

  def find_alternative_format_provider
    @alternative_format_provider = Organisation.find(params[:alternative_format_provider_id]) if params[:alternative_format_provider_id]
    @alternative_format_contact_email = @alternative_format_provider && @alternative_format_provider.alternative_format_contact_email
  rescue ActiveRecord::RecordNotFound
    nil
  end

private
  def limit_access_to_attachments!
    unless @attachments.all? { |a| a.accessible_by?(current_user) }
      render "admin/editions/forbidden", status: 403
    end
  end
end
