class StatisticalDataSet < Publicationesque
  include Edition::HasDocumentSeries
  include Edition::AlternativeFormatProvider

  def allows_attachment_references?
    true
  end

  def self.access_limited_by_default?
    true
  end

  def display_type_key
    "statistical_data_set"
  end

  def search_format_types
    super + ['publicationesque-statistics', StatisticalDataSet.search_format_type]
  end
end
