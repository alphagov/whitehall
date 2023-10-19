class CaseStudy < Edition
  include Edition::Images
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::TaggableOrganisations
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations
  include Edition::LeadImage

  after_update :update_lead_image, if: :saved_change_to_image_display_option?

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

  def update_lead_image
    if image_display_option == "no_image"
      update_column(:lead_image_id, nil)
    elsif lead_image.blank? && images.present?
      update_column(:lead_image_id, oldest_image.id)
    end
  end
end
