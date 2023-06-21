module AttachmentsHelper
  def default_url_options
    { host: Plek.website_root, protocol: "https" }
  end

  def previewable?(attachment)
    attachment.csv? && attachment.attachable.is_a?(Edition)
  end

  def preview_path_for_attachment(attachment)
    "/uploads/system/uploads/attachment_data/file/#{attachment.attachment_data.id}/#{attachment.filename}/preview"
  end

  def block_attachments(attachments = [],
                        alternative_format_contact_email = nil,
                        published_on = nil)
    attachments.collect do |attachment|
      render(
        partial: "documents/attachment",
        formats: :html,
        object: attachment,
        locals: {
          alternative_format_contact_email:,
          published_on:,
        },
      )
    end
  end
end
