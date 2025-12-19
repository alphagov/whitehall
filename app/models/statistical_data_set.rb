# Statistical data sets live at https://www.gov.uk/government/statistical-data-sets
#
# Example:
#  https://www.gov.uk/government/statistical-data-sets/2011-skills-for-life-survey-small-area-estimation-data
#
class StatisticalDataSet < Edition
  include Edition::AlternativeFormatProvider
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::TaggableOrganisations

  include ::Attachable

  def allows_attachment_references?
    true
  end

  def self.access_limited_by_default?
    true
  end

  def rendering_app
    Whitehall::RenderingApp::FRONTEND
  end

  def base_path
    "/government/statistical-data-sets/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def publishing_api_presenter
    PublishingApi::StatisticalDataSetPresenter
  end
end
