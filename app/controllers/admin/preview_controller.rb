class Admin::PreviewController < Admin::BaseController
  before_filter :find_attachments
  before_filter :limit_attachment_access!

  def preview
    if Govspeak::HtmlValidator.new(params[:body]).valid?
      @images = Image.find(params.fetch(:image_ids, []))
      @alternative_format_contact_email = alternative_format_contact_email
      render layout: false
    else
      render text: "Content contains possible XSS exploits", status: :forbidden
    end
  end

private

  def alternative_format_contact_email
    Organisation.find_by_id(params[:alternative_format_provider_id]).try(:alternative_format_contact_email)
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
