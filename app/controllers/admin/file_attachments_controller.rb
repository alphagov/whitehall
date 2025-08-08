class Admin::FileAttachmentsController < Admin::AttachmentsController
  def new; end

  def edit; end

  def update
    notice = "Attachment '#{attachment.title}' updated"

    attachment.attachment_data.attachable = attachable
    if attachment.filename_changed? && attachable.allows_inline_attachments?
      notice += ". You must replace the attachment markdown with the new markdown below."
    end

    if save_attachment
      save_and_redirect(notice)
    else
      render :edit
    end
  end

  def attachment_params
    attachment_params = params.fetch(:attachment, {}).permit(
      :title,
      :locale,
      :isbn,
      :unique_reference,
      :command_paper_number,
      :unnumbered_command_paper,
      :hoc_paper_number,
      :unnumbered_hoc_paper,
      :parliamentary_session,
      :accessible,
      :external_url,
      :visual_editor,
      govspeak_content_attributes: %i[id body manually_numbered_headings],
      attachment_data_attributes: %i[file to_replace_id file_cache],
    ).merge(attachable:)

    clear_file_cache(attachment_params)
  end

private

  def clear_file_cache(attachment_params)
    if attachment_params.dig(:attachment_data_attributes, :file_cache).present? && attachment_params.dig(:attachment_data_attributes, :file).present?
      attachment_params[:attachment_data_attributes].delete(:file_cache)
    end

    attachment_params
  end

  def build_attachment
    FileAttachment.new(attachment_params).tap do |file_attachment|
      file_attachment.build_attachment_data unless file_attachment.attachment_data
      file_attachment.attachment_data.attachable = attachable
    end
  end
end
