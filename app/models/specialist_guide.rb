class SpecialistGuide < Edition
  include Edition::Topics
  include Edition::Attachable
  include Edition::FactCheckable

  def has_summary?
    true
  end

  def allows_body_to_be_paginated?
    true
  end
end
