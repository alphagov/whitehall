module Edition::AccessControl
  def editable?
    imported? || draft? || submitted? || rejected?
  end

  def can_have_some_invalid_data?
    imported? || deleted? || archived?
  end

  def rejectable_by?(user)
    submitted? && enforcer(user).can?(:reject)
  end

  def approvable_retrospectively_by?(user)
    !reason_to_prevent_retrospective_approval_by(user)
  end

  def reason_to_prevent_retrospective_approval_by(user)
    if !force_published?
      "This document has not been force-published"
    elsif scheduled_by && user == scheduled_by
      "You are not allowed to retrospectively approve this document, since you force-scheduled it"
    elsif user == published_by
      "You are not allowed to retrospectively approve this document, since you force-published it"
    elsif !enforcer(user).can?(:approve)
      "Only departmental editors can retrospectively approve a force-published document"
    end
  end
end
