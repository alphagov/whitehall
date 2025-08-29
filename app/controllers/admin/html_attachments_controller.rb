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
      govspeak_content_attributes: %i[id body manually_numbered_headings],
    ).merge(attachable:)
  end

  def edition_image_ids
    return [] unless attachable_is_an_edition?

    attachable.images.pluck(:id)
  end
  helper_method :edition_image_ids

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
    end
  end
end
