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
  
  def rejectable?
    submitted?
  end
end
