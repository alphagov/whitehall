module Document::Publishing
  def publishable_by?(user, options = {})
    reason_to_prevent_publication_by(user, options).nil?
  end

  def reason_to_prevent_publication_by(user, options = {})
    if published?
      "This edition has already been published"
    elsif archived?
      "This edition has been archived"
    elsif !submitted? && !options[:force]
      "Not ready for publication"
    elsif user == author && !options[:force]
      "You are not the second set of eyes"
    elsif !user.departmental_editor?
      "Only departmental editors can publish"
    end
  end

  def publish_as(user, options = {})
    if publishable_by?(user, options)
      self.lock_version = lock_version
      publish!
      true
    else
      errors.add(:base, reason_to_prevent_publication_by(user, options))
      false
    end
  end
end