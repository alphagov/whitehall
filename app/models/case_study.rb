class CaseStudy < Edition
  include ::Attachable
  include Edition::Images
  include Edition::FactCheckable
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::TaggableOrganisations
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations
  include GovspeakHelper

  has_one :edition_lead_image, foreign_key: :edition_id, dependent: :destroy
  has_one :lead_image, through: :edition_lead_image, source: :image

  validate :body_does_not_contain_lead_image

  def rendering_app
    Whitehall::RenderingApp::FRONTEND
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

  def has_lead_image?
    !image_data.nil?
  end

  def lead_image_url
    image_url
  end

  def high_resolution_lead_image_url
    image_data.file.url(:s960)
  end

  def lead_image_caption
    if lead_image
      caption = lead_image.caption && lead_image.caption.strip
      caption.presence
    end
  end

  def lead_image_has_all_assets?
    image_data.all_asset_variants_uploaded?
  end

  def update_lead_image
    if %w[no_image organisation_image].include?(image_display_option)
      remove_lead_image
      return
    end

    return if lead_image.present? || images.blank?

    image = oldest_image_that_can_be_lead_image

    if image
      edition_lead_image = build_edition_lead_image(image:)
      edition_lead_image.save!
    end
  end

  def non_lead_images
    images - [lead_image].compact
  end

private

  def image_url
    image_data.file.url(:s300)
  end

  def image_data
    if lead_image
      lead_image.image_data
    elsif lead_organisations.any? && lead_organisations.first.default_news_image
      lead_organisations.first.default_news_image
    elsif organisations.any? && organisations.first.default_news_image
      organisations.first.default_news_image
    elsif respond_to?(:worldwide_organisations) && published_worldwide_organisations.any? && published_worldwide_organisations.first.default_news_image
      published_worldwide_organisations.first.default_news_image
    end
  end

  def uploader
    image_data.file
  end

  def file
    uploader.file
  end

  def oldest_image_that_can_be_lead_image
    images.includes(:image_data).detect(&:can_be_lead_image?)
  end

  def remove_lead_image
    return if edition_lead_image.blank?

    edition_lead_image.destroy!
  end

  def body_does_not_contain_lead_image
    return if edition_lead_image.blank? || images.none?

    html = govspeak_edition_to_html(self)
    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    if doc.css("img[src*='#{edition_lead_image.image.filename}']").present?
      errors.add(:body, "cannot have a reference to the lead image in the text")
    end
  end
end
