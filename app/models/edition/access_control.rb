module Edition::AccessControl
  def editable?
    imported? || draft? || submitted? || rejected?
  end

  def can_have_some_invalid_data?
    imported? || deleted? || archived?
  end
end
