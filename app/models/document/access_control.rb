module Document::AccessControl
  extend ActiveSupport::Concern

  def editable_by?(user)
    draft?
  end

  def submittable_by?(user)
    draft? && !submitted?
  end

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

end
