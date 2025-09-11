class CaseStudy < Edition
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
    Whitehall::RenderingApp::FRONTEND
  end

  def display_type_key
    "case_study"
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
