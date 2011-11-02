module Document::AccessControl
  extend ActiveSupport::Concern

  def editable_by?(user)
    draft?
  end

  def submittable_by?(user)
    draft? && !submitted?
  end
end
