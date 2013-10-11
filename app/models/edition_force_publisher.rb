class EditionForcePublisher < EditionPublisher

  def perform!
    if can_perform?
      edition.force_published = true
      edition.access_limited  = false
      set_publishing_timestamps
      edition.increment_version_number
      edition.force_publish!
      edition.archive_previous_editions!
      edition.editorial_remarks.create(body: "Force published: #{force_publish_reason}", author: user)
      true
    end
  end

  def failure_reason
    @failure_reason ||= if !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    elsif force_publish_reason.blank?
      'You cannot force publish an edition without a reason'
    elsif !edition.can_force_publish?
      "An edition that is #{edition.current_state} cannot be force published"
    end
  end

private

  def force_publish_reason
    @options[:reason]
  end

  def user
    @options[:user]
  end
end
