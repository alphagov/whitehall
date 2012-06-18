class SpecialistGuide < Edition
  include Edition::Topics

  def has_summary?
    true
  end
end
