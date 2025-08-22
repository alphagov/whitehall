class Admin::ExternalAttachmentsController < Admin::AttachmentsController
  def new; end

  def edit; end

private

  def attachment_params
    params.fetch(:attachment, {}).permit(
      :title,
      :locale,
      :isbn,
      :unique_reference,
      :command_paper_number,
      :unnumbered_command_paper,
      :hoc_paper_number,
      :unnumbered_hoc_paper,
      :parliamentary_session,
      :external_url,
    ).merge(attachable:)
  end

  def build_attachment
    ExternalAttachment.new(attachment_params)
  end
end
