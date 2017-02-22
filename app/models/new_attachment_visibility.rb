class NewAttachmentVisibility
  attr_reader :attachment_data, :user

  def initialize(attachment_data, user)
    @attachment_data = attachment_data
    @user = user
  end

  def visible?
    attachment_data.present? &&
      has_an_undeleted_attachment? &&
      (
        is_not_related_to_an_edition? ||
         (is_related_to_a_visible_edition? && is_visible_to_the_user?)
      )
  end

  def visible_edition
    related_visible_editions.last
  end

  def visible_attachment
    if visible_edition
      (visible_edition.attachments & attachment_data.attachments).last
    end
  end

private

  def has_an_undeleted_attachment?
    undeleted_attachments.any?
  end

  def undeleted_attachments
    attachment_data.attachments.not_deleted
  end

  def is_not_related_to_an_edition?
    related_editions.empty?
  end

  def is_related_to_a_visible_edition?
    related_visible_editions.any?
  end

  def related_visible_editions
    related_editions.select do |edition|
      Edition::PUBLICLY_VISIBLE_STATES.include?(edition.state)
    end
  end

  def is_visible_to_the_user?
    user.nil? || Edition.accessible_to(user)
      .where(id: related_visible_editions.map(&:id)).any?
  end

  def related_editions
    attachment_data.attachments.not_deleted
      .map(&:attachable)
      .select { |attachable| attachable.class <= Edition }
  end
end
