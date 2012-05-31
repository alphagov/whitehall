module Edition::AccessControl
  extend ActiveSupport::Concern

  def deletable?
    draft? || submitted? || rejected? || only_edition?
  end

  def editable?
    draft? || submitted? || rejected?
  end

  def submittable?
    draft? || rejected?
  end

  def rejectable_by?(user)
    submitted? && user.departmental_editor?
  end

  def force_published_can_be_cleared_by?(user)
    !reason_to_prevent_force_published_being_cleared_by(user)
  end

  def reason_to_prevent_force_published_being_cleared_by(user)
    if !force_published?
      "This document has not been force-published"
    elsif user == creator
      "You are not allowed to clear the force-published state of this document, since you created it"
    end
  end
end
