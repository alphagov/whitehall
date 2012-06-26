class SpecialistGuide < Edition
  include Edition::Topics
  include Edition::Attachable
  include Edition::FactCheckable

  def has_summary?
    true
  end
end
