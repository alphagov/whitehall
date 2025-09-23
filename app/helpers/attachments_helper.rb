module AttachmentsHelper
  ATTACHMENT_COMPONENT_TYPES = {
    FileAttachment => "file",
    HtmlAttachment => "html",
    ExternalAttachment => "external",
  }.freeze

  def default_url_options
    { host: Plek.website_root, protocol: "https" }
  end

  def prepare_attachments(attachments)
    attachments
      .select { |attachment| !attachment.file? || attachment.attachment_data&.all_asset_variants_uploaded? }
      .map(&:publishing_component_params)
  end

  def block_attachments(attachments = [])
    attachments
      .select { |attachment| !attachment.file? || attachment.attachment_data.all_asset_variants_uploaded? }
      .map do |attachment|
      render(
        partial: "govuk_publishing_components/components/attachment",
        locals: {
          attachment: attachment.publishing_component_params,
          margin_bottom: 6,
        },
      )
    end
  end

  def bulk_attachment_errors(attachments = nil)
    return if attachments.blank?

    items = attachments.map(&:errors).flat_map.with_index do |errors, index|
      errors.map do |error|
        {
          text: text = "#{attachments[index].attachment_data.filename}: #{error.full_message.humanize}",
          href: "#bulk_upload[attachments][#{index}]_#{error.attribute.to_s.gsub('.', '_')}",
          data_attributes: {
            module: "ga4-auto-tracker",
            "ga4-auto": {
              event_name: "form_error",
              type: "Bulk Upload File Attachment",
              text:,
              section: error.attribute.to_s.humanize,
              action: "error",
            }.to_json,
          },
        }
      end
    end

    return if items.blank?

    render "govuk_publishing_components/components/error_summary", {
      title: "There is a problem",
      items:,
    }
  end
end
