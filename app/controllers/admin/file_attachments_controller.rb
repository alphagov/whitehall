class Admin::FileAttachmentsController < Admin::AttachmentsController
  def new; end

  def edit; end

private

  def build_attachment
    FileAttachment.new(attachment_params).tap do |file_attachment|
      file_attachment.build_attachment_data unless file_attachment.attachment_data
      file_attachment.attachment_data.attachable = attachable
    end
  end
end
