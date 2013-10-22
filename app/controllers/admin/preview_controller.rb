class Admin::PreviewController < Admin::BaseController
  before_filter :find_attachments
  before_filter :limit_attachment_access!

  def preview
    @images = Image.find(params.fetch(:image_ids, []))
    find_alternative_format_provider

    if Govspeak::HtmlValidator.new(params[:body]).valid?
      render layout: false
    else
      render text: "Content contains possible XSS exploits", status: :forbidden
    end
  end

private

  def find_alternative_format_provider
    @alternative_format_provider = Organisation.find(params[:alternative_format_provider_id]) if params[:alternative_format_provider_id]
    @alternative_format_contact_email = @alternative_format_provider && @alternative_format_provider.alternative_format_contact_email
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def find_attachments
    @attachments = Attachment.find(params.fetch(:attachment_ids, []))
  end

  def limit_attachment_access!
    if @attachments.any? { |attachment| !can?(:see, attachment.attachable) }
      forbidden!
    end
  end
end
