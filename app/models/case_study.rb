class CaseStudy < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::TaggableOrganisations
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations

  validates :first_published_at, presence: true, if: ->(e) { e.trying_to_convert_to_draft == true }

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
end
