class Admin::PreviewController < Admin::BaseController
  before_action :find_attachments
  before_action :limit_attachment_access!
  include GovspeakHelper

  def preview
    if Govspeak::HtmlValidator.new(params[:body]).valid?
      @images = Image.find(params.fetch(:image_ids, []))
      @alternative_format_contact_email = alternative_format_contact_email
      @embeds = fetch_embeds(params[:body])
      render layout: false
    else
      render plain: "Content contains possible XSS exploits", status: :forbidden
    end
  end

private
  def fetch_embeds(govspeak)
    content_ids = Govspeak::EmbedExtractor.new(govspeak).content_ids
    documents = ContentBlockManager::ContentBlock::Document.live.where(content_id: content_ids)
    editions = ContentBlockManager::ContentBlock::Edition.where(id: documents.map(&:live_edition_id))
    editions.map do |edition|
      {
        content_id: edition.document.content_id,
        document_type: "content_block_#{edition.block_type}",
        title: edition.title,
        details: edition.details
      }
    end
  end

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
