module Edition::AccessControl
  extend ActiveSupport::Concern

  def deletable?
    imported? || draft? || submitted? || rejected?
  end

  def editable?
    imported? || draft? || submitted? || rejected?
  end

  def submittable?
    draft? || rejected?
  end

  def can_have_some_invalid_data?
    imported? || deleted?
  end

  def ready_to_convert_to_draft?
    imported? && valid_as_draft?
  end

  def rejectable_by?(user)
    submitted? && user.departmental_editor?
  end

  def approvable_retrospectively_by?(user)
    !reason_to_prevent_retrospective_approval_by(user)
  end

  def reason_to_prevent_retrospective_approval_by(user)
    if !force_published?
      "This document has not been force-published"
    elsif !user.departmental_editor?
      "Only departmental editors can retrospectively approve a force-published document"
    elsif scheduled_by && user == scheduled_by
      "You are not allowed to retrospectively approve this document, since you force-scheduled it"
    elsif user == published_by
      "You are not allowed to retrospectively approve this document, since you force-published it"
    end
  end
end
