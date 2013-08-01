class AttachmentVisibility
  attr_reader :attachment_data, :user

  def initialize(attachment_data, user)
    @attachment_data = attachment_data
    @user = user
  end

  def visible?
    visible_edition? || visible_corporate_information_page? || visible_policy_group?
  end

  def unpublished_edition
    if unpublishing = Unpublishing.where(edition_id: edition_ids).first
      Edition.unscoped.find(unpublishing.edition_id)
    end
  end

  private

  def id
    attachment_data.id
  end

  def visible_edition?
    if user
      Edition.accessible_to(user).where(id: edition_ids).exists?
    else
      Edition.published.where(id: edition_ids).exists?
    end
  end

  def visible_corporate_information_page?
    CorporateInformationPage.joins(:attachments).where(attachments: {attachment_data_id: id}).exists?
  end

  def visible_policy_group?
    PolicyAdvisoryGroup.joins(:attachments).where(attachments: {attachment_data_id: id}).exists?
  end

  def edition_ids
    @edition_ids ||= [ EditionAttachment.joins(:attachment).where(attachments: {attachment_data_id: id}).pluck(:edition_id),
                       Response.joins(:attachments).where(attachments: {attachment_data_id: id}).pluck(:edition_id),
                       SupportingPage.joins(:attachments).where(attachments: {attachment_data_id: id}).pluck(:edition_id)
                     ].flatten.uniq
  end
end
