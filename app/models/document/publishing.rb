module Document::Publishing
  def publishable_by?(user)
    reason_to_prevent_publication_by(user).nil?
  end

  def reason_to_prevent_publication_by(user)
    if published?
      "This edition has already been published"
    elsif archived?
      "This edition has been archived"
    elsif !submitted?
      "Not ready for publication"
    elsif user == author
      "You are not the second set of eyes"
    elsif !user.departmental_editor?
      "Only departmental editors can publish"
    end
  end

  def publish_as(user)
    if publishable_by?(user)
      self.lock_version = lock_version
      publish!
      true
    else
      errors.add(:base, reason_to_prevent_publication_by(user))
      false
    end
  end
end