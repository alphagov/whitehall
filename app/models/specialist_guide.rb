class SpecialistGuide < Edition
  include Edition::Topics
  include Edition::Attachable

  def has_summary?
    true
  end
end
