class StatisticalDataSet < Publicationesque
  include Edition::DocumentSeries
  include Edition::AlternativeFormatProvider

  def allows_attachment_references?
    true
  end

  def self.access_limited_by_default?
    true
  end
end
