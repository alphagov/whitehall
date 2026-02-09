module AttachmentsHelper
  def attachment_errors(attachments = nil)
    return if attachments.blank?

    items = attachments.map(&:errors).flat_map.with_index do |errors, index|
      errors.map do |error|
        {
          text: text = "#{attachments[index].attachment_data.filename}: #{error.full_message.humanize}",
          href: "#upload[attachments][#{index}]_#{error.attribute.to_s.gsub('.', '_')}",
          data_attributes: {
            module: "ga4-auto-tracker",
            "ga4-auto": {
              event_name: "form_error",
              type: "Upload File Attachment",
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
