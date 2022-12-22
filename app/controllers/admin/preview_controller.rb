class Admin::PreviewController < Admin::BaseController
  before_action :find_attachments
  before_action :limit_attachment_access!
  include GovspeakHelper

  def preview
    if Govspeak::HtmlValidator.new(params[:body]).valid?
      model_images = Image.find(params.fetch(:image_ids, []))
      @images = prepare_images model_images
      @alternative_format_contact_email = alternative_format_contact_email
      render layout: false
    else
      render plain: "Content contains possible XSS exploits", status: :forbidden
    end
  end

private

  def alternative_format_contact_email
    return if alternative_format_provider_id.blank?

    if (organisation = Organisation.friendly.find(alternative_format_provider_id))
      organisation.alternative_format_contact_email
    end
  end

  def alternative_format_provider_id
    params[:alternative_format_provider_id]
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
