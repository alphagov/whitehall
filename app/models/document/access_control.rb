module Document::AccessControl
  extend ActiveSupport::Concern

  def deletable?
    draft? || submitted? || rejected?
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
end
