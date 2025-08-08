class Admin::HtmlAttachmentsController < Admin::AttachmentsController
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
      :visual_editor,
      govspeak_content_attributes: %i[id body manually_numbered_headings],
    ).merge(attachable:)
  end

  def save_attachment
    super

    if attachment.valid? && !attachable_is_an_edition?
      Whitehall::PublishingApi.save_draft(attachment)
    end

    attachment.valid?
  end

  def build_attachment
    HtmlAttachment.new(attachment_params).tap do |attachment|
      attachment.build_govspeak_content if attachment.govspeak_content.blank?
      if attachment.visual_editor.nil?
        attachment.visual_editor = Flipflop.govspeak_visual_editor? && current_user.can_see_visual_editor_private_beta?
      end
    end
  end
end
