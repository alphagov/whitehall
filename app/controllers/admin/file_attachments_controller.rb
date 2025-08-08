class Admin::FileAttachmentsController < Admin::AttachmentsController
  before_action :redirect_to_attachments_index, only: %i[new]

  def edit; end

private

  def redirect_to_attachments_index
    redirect_to attachable_attachments_path(attachable)
  end

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
