class Admin::HtmlAttachmentsController < Admin::AttachmentsController
  before_action :save_draft, only: %i[create update], if: :save_attachment

  def new; end

  def edit; end

private

  def save_draft
    Whitehall::PublishingApi.save_draft(attachment)
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
