module Document::AccessControl
  extend ActiveSupport::Concern

  def deletable?
    draft?
  end

  def editable?
    draft?
  end

  def submittable?
    draft? && !submitted?
  end
end
