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
end
