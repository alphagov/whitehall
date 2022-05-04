module AttachmentsHelper
  def default_url_options
    { host: Plek.new.website_root, protocol: "https" }
  end

  def previewable?(attachment)
    attachment.csv? && attachment.attachable.is_a?(Edition)
  end

  # Until we have sensible (resourceful) routing for serving attachments, this method
  # provides a convenient shorthand for generating a path for attachment preview.
  def preview_path_for_attachment(attachment)
    csv_preview_path(id: attachment.attachment_data.id, file: attachment.filename_without_extension, extension: attachment.file_extension)
  end

  def participating_in_accessible_format_request_pilot?(contact_email)
    # A small number of organisations are taking part in a pilot scheme for accessible
    # format requests to be submitted by a form rather than a direct email
    pilot_addresses = GovukPublishingComponents::Presenters::AttachmentHelper::EMAILS_IN_ACCESSIBLE_FORMAT_REQUEST_PILOT
    pilot_addresses.include?(contact_email)
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
          alternative_format_contact_email: alternative_format_contact_email,
          published_on: published_on,
        },
      )
    end
  end
end
