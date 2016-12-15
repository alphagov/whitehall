# Statistical data sets live at https://www.gov.uk/government/statistical-data-sets
#
# Example:
#  https://www.gov.uk/government/statistical-data-sets/2011-skills-for-life-survey-small-area-estimation-data
#
class StatisticalDataSet < Publicationesque
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

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end
end
