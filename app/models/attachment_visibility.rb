class AttachmentVisibility
  attr_reader :attachment_data, :user

  def initialize(attachment_data, user)
    @attachment_data = attachment_data
    @user = user
  end

  def visible?
    visible_edition? ||
    visible_consultation_response? ||
    visible_corporate_information_page? ||
    visible_supporting_page? ||
    visible_policy_group?
  end

  private

  def attachment_data_id
    attachment_data.id
  end

  def visible_edition?
    if edition_ids = EditionAttachment.joins(:attachment).
        where(attachments: {attachment_data_id: attachment_data_id}).map(&:edition_id)
      any_edition_visible?(edition_ids)
    end
  end

  def visible_consultation_response?
    if edition_ids = Response.joins(:attachments).
        where(attachments: {attachment_data_id: attachment_data_id}).map(&:edition_id)
      any_edition_visible?(edition_ids)
    end
  end

  def visible_corporate_information_page?
    CorporateInformationPage.joins(:attachments).
      where(attachments: {attachment_data_id: attachment_data_id}).exists?
  end

  def visible_supporting_page?
    if edition_ids = SupportingPage.joins(:attachments).
        where(attachments: {attachment_data_id: attachment_data_id}).map(&:edition_id)
      any_edition_visible?(edition_ids)
    end
  end

  def visible_policy_group?
    # Policy groups don't have workflows, so they're always live
    PolicyAdvisoryGroup.joins(:attachments).
      where(attachments: {attachment_data_id: attachment_data_id}).exists?
  end

  def any_edition_visible?(ids)
    if user
      Edition.accessible_to(user).where(id: ids).exists?
    else
      Edition.published.where(id: ids).exists?
    end
  end
end