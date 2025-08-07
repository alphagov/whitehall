class Admin::ExternalAttachmentsController < Admin::NewAttachmentsController
  def new; end

  def edit; end

private
  def build_attachment
    ExternalAttachment.new(attachment_params)
  end
end
