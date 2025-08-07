class Admin::FileAttachmentsController < Admin::NewAttachmentsController
  before_action :set_attachable, only: [:update]
  before_action :set_notice, only: [:update], if: :save_attachment

  def edit; end

private
  def clear_file_cache(attachment_params)
    if attachment_params.dig(:attachment_data_attributes, :file_cache).present? && attachment_params.dig(:attachment_data_attributes, :file).present?
      attachment_params[:attachment_data_attributes].delete(:file_cache)
    end

    attachment_params
  end

  def set_attachable
    attachment.attachment_data.attachable = attachable
  end

  def set_notice
    if attachment.filename_changed? && attachable.allows_inline_attachments?
      flash[:alert] = "You must replace the attachment markdown with the new markdown below."
    end
  end
end
