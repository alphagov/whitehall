module Document::AccessControl
  extend ActiveSupport::Concern

  def deletable?
    draft? || submitted?
  end

  def editable?
    draft? || submitted?
  end

  def submittable?
    draft?
  end
end
