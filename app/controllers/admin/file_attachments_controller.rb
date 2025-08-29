class Admin::FileAttachmentsController < Admin::AttachmentsController
  before_action :redirect_to_attachments_index, only: %i[new]

  def edit; end

  def update
    if save_attachment
      flash[:notice] = "Attachment '#{attachment.title}' updated"

      if attachment.filename_changed? && attachable.allows_inline_attachments?
        flash[:notice] += ". You must replace the attachment markdown with the new markdown below."
      end

      save_and_redirect
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
      attachment_data_attributes: %i[file to_replace_id file_cache],
    ).merge(attachable:)

    clear_file_cache(attachment_params)
  end

private

  def update_attachment_params
    super

    attachment.attachment_data.attachable = attachable
  end

  def clear_file_cache(attachment_params)
    if attachment_params.dig(:attachment_data_attributes, :file_cache).present? && attachment_params.dig(:attachment_data_attributes, :file).present?
      attachment_params[:attachment_data_attributes].delete(:file_cache)
    end

    attachment_params
  end
end
