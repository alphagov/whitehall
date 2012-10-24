class StatisticalDataSet < Edition
  include Edition::DocumentSeries
  include ::Attachable
  include Edition::AlternativeFormatProvider

  attachable :edition

  def allows_attachment_references?
    true
  end

  def can_have_summary?
    true
  end
end