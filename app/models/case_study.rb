class CaseStudy < Edition
  include Edition::Searchable

  include ::Attachable
  include Edition::Images
  include Edition::FactCheckable
  include Edition::CustomLeadImage
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::TaggableOrganisations
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations
  include Edition::LeadImage

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def display_type_key
    "case_study"
  end

  def search_format_types
    super + [CaseStudy.search_format_type]
  end

  def translatable?
    !non_english_edition?
  end

  def base_path
    "/government/case-studies/#{slug}"
  end

  def publishing_api_presenter
    PublishingApi::CaseStudyPresenter
  end

  def emphasised_organisation_default_image_available?
    lead_organisations.first&.default_news_image.present?
  end
end
