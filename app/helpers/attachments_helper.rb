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

  def upload_success_notice_message(attachments)
    if attachments.size > 5
      content_tag(:p, "#{attachments.size} attachments successfully saved", class: "govuk-notification-banner__heading")
    else
      content_tag(:ul) do
        attachments.each do |attachment|
          concat content_tag(
            :li,
            "Attachment '#{attachment.title}' #{attachment.attachment_data.to_replace_id.present? ? 'updated' : 'uploaded'}".html_safe,
            class: "govuk-notification-banner__heading",
          )
        end
      end
    end
  end
end
