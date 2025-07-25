class DetailedGuide < Edition
  include Edition::Images
  include Edition::NationalApplicability

  include ::Attachable
  include Edition::AlternativeFormatProvider
  include Edition::FactCheckable
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::TaggableOrganisations
  include Edition::RelatedDocuments
  include Edition::TopicalEvents

  def self.format_name
    "detailed guidance"
  end

  has_many :related_mainstreams, foreign_key: "edition_id", dependent: :destroy

  validate :related_mainstream_found, if: :related_mainstream_requested?

  after_save :persist_content_ids

  class HeadingHierarchyValidator < ActiveModel::Validator
    include GovspeakHelper
    def validate(record)
      govspeak_header_hierarchy(record.body)
    rescue Govspeak::OrphanedHeadingError => e
      record.errors.add(:body, "must have a level-2 heading (h2 - ##) before level-3 heading (h3 - ###): '#{e.heading}'")
    end
  end

  validates_with HeadingHierarchyValidator

  def rendering_app
    Whitehall::RenderingApp::FRONTEND
  end

  def related_detailed_guide_ids
    related_to_editions.where(type: "DetailedGuide").pluck(:id)
  end

  def related_detailed_guide_content_ids
    published_related_detailed_guides.map(&:content_id)
  end

  # Ensure that we set related detailed guides without stomping on other related documents
  def related_detailed_guide_ids=(detailed_guide_ids)
    detailed_guide_ids        = Array.wrap(detailed_guide_ids).reject(&:blank?)
    other_related_documents   = related_documents.reject { |document| document.document_type == "DetailedGuide" }
    detailed_guide_documents  = DetailedGuide.find(detailed_guide_ids).map(&:document)

    self.related_documents = other_related_documents + detailed_guide_documents
  end

  def published_related_detailed_guides
    (published_outbound_related_detailed_guides + published_inbound_related_detailed_guides).uniq
  end

  def can_be_related_to_mainstream_content?
    true
  end

  def has_related_mainstream_content?
    related_mainstream_content_url.present?
  end

  def has_additional_related_mainstream_content?
    additional_related_mainstream_content_url.present?
  end

  def display_type_key
    "detailed_guidance"
  end

  def translatable?
    true
  end

  def related_mainstream_base_path
    url = related_mainstream_content_url
    parse_base_path_from_related_mainstream_url(url)
  end

  def additional_related_mainstream_base_path
    url = additional_related_mainstream_content_url
    parse_base_path_from_related_mainstream_url(url)
  end

  def related_mainstream_content_ids
    @related_mainstream_content_ids ||= begin
      base_paths = [related_mainstream_base_path, additional_related_mainstream_base_path].compact
      return [] if base_paths.empty?

      response_hash = Services.publishing_api.lookup_content_ids(base_paths:)
      response_hash.values_at(*base_paths)
    end
  end

  def government
    @government ||= Government.on_date(date_for_government) unless date_for_government.nil?
  end

  def persist_content_ids
    related_mainstreams.delete_all
    related_mainstreams.create!(content_id: related_mainstream_content_ids[0]) if related_mainstream_content_ids[0]
    related_mainstreams.create!(content_id: related_mainstream_content_ids[1], additional: true) if related_mainstream_content_ids[1]
  end

  def all_nation_applicability_selected?
    newly_created = document.nil? || document.new_record?
    newly_created ? false : all_nation_applicability
  end

  def base_path
    "/guidance/#{slug}"
  end

  def publishing_api_presenter
    PublishingApi::DetailedGuidePresenter
  end

private

  def date_for_government
    published_edition_date = first_public_at.try(:to_date)
    draft_edition_date = updated_at.try(:to_date)
    published_edition_date || draft_edition_date
  end

  # Returns the live edition of any detailed guide documents that this edition is related to.
  def published_outbound_related_detailed_guides
    related_documents.live.where(document_type: "DetailedGuide").map(&:live_edition).compact
  end

  # Returns the published editions that are related to this edition's document.
  def published_inbound_related_detailed_guides
    DetailedGuide.published.joins(:outbound_edition_relations).where(edition_relations: { document_id: document.id })
  end

  def parse_base_path_from_related_mainstream_url(url)
    return nil if url.blank?

    begin
      parsed_url = URI.parse(url.strip)
      url_is_invalid = !["gov.uk", "www.gov.uk"].include?(parsed_url.host)
      url_is_invalid ? nil : parsed_url.path
    rescue URI::InvalidURIError
      nil
    end
  end

  def related_mainstream_found
    if missing_related_mainstream?
      errors.add(:related_mainstream_content_url, "This mainstream content could not be found")
    end
    if missing_additional_related_mainstream?
      errors.add(:additional_related_mainstream_content_url, "This mainstream content could not be found")
    end
  end

  def missing_related_mainstream?
    related_mainstream_content_url.present? &&
      related_mainstream_content_ids.count >= 1 &&
      related_mainstream_content_ids[0].nil?
  end

  def missing_additional_related_mainstream?
    additional_related_mainstream_content_url.present? &&
      related_mainstream_content_ids.count > 1 &&
      related_mainstream_content_ids[1].nil?
  end

  def related_mainstream_requested?
    related_mainstream_content_url.present? || additional_related_mainstream_content_url.present?
  end
end
