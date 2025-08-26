module AttachmentsHelper
  ATTACHMENT_COMPONENT_TYPES = {
    FileAttachment => "file",
    HtmlAttachment => "html",
    ExternalAttachment => "external",
  }.freeze

  def default_url_options
    { host: Plek.website_root, protocol: "https" }
  end

  def previewable?(attachment)
    attachment.csv? && attachment.attachable.is_a?(Edition)
  end

  def preview_path_for_attachment(attachment)
    if attachment.attachment_data.all_asset_variants_uploaded?
      "/csv-preview/#{attachment.attachment_data.assets.first.asset_manager_id}/#{attachment.attachment_data.assets.first.filename}"
    end
  end

  def prepare_attachments(attachments, alternative_format_contact_email)
    attachments
      .select { |attachment| !attachment.file? || attachment.attachment_data&.all_asset_variants_uploaded? }
      .map do |attachment|
      attachment_component_params(attachment, alternative_format_contact_email:)
    end
  end

  def attachment_component_params(attachment, alternative_format_contact_email: nil)
    params = {
      type: ATTACHMENT_COMPONENT_TYPES.fetch(attachment.class),
      title: attachment.title,
      url: attachment.url,
      isbn: attachment.isbn.presence,
      unique_reference: attachment.unique_reference.presence,
      command_paper_number: attachment.command_paper_number.presence,
      unnumbered_command_paper: attachment.unnumbered_command_paper? || nil,
      hoc_paper_number: attachment.hoc_paper_number.presence,
      unnumbered_hoc_paper: attachment.unnumbered_hoc_paper? || nil,
      parliamentary_session: attachment.parliamentary_session.presence,
    }

    # File attachments get some extra parameters, including 'id' so
    # they can be embedded in Govspeak using [Attachment:XX] syntax
    if attachment.file?
      params[:id] = attachment.filename
      params[:content_type] = attachment.content_type
      params[:filename] = attachment.filename
      params[:file_size] = attachment.file_size
    end

    if attachment.pdf?
      params[:number_of_pages] = attachment.number_of_pages
    end

    # CSV attachments on an Edition get a "View online" preview link
    if previewable?(attachment)
      params[:preview_url] = preview_path_for_attachment(attachment)
    end

    # Inaccessible attachments can have alt format contact info
    unless attachment.accessible?
      params[:alternative_format_contact_email] = alternative_format_contact_email
    end

    params.compact
  end

  def block_attachments(attachments = [], alternative_format_contact_email = nil)
    attachments
      .select { |attachment| !attachment.file? || attachment.attachment_data.all_asset_variants_uploaded? }
      .map do |attachment|
      render(
        partial: "govuk_publishing_components/components/attachment",
        locals: {
          attachment: attachment_component_params(attachment, alternative_format_contact_email:),
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
