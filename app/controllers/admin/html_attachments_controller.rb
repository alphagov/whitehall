class Admin::HtmlAttachmentsController < Admin::AttachmentsController
  def new; end

  def edit; end

private

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
