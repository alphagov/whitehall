class DetailedGuide < Edition
  include Edition::Images
  include Edition::NationalApplicability

  # DID YOU MEAN: Policy Area?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  # You can help improve this code by renaming all usages of this field to use
  # the new terminology.
  include Edition::Topics

  include ::Attachable
  include Edition::AlternativeFormatProvider
  include Edition::FactCheckable
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::RelatedPolicies
  include Edition::RelatedDocuments

  validate :related_mainstream_content_valid?
  validate :additional_related_mainstream_content_valid?

  class HeadingHierarchyValidator < ActiveModel::Validator
    include GovspeakHelper
    def validate(record)
      govspeak_header_hierarchy(record.body)
    rescue OrphanedHeadingError => e
      record.errors.add(:body, "must have a level-2 heading (h2 - ##) before level-3 heading (h3 - ###): '#{e.heading}'")
    end
  end

  validates_with HeadingHierarchyValidator

  def rummager_index
    :detailed_guides
  end

  def related_detailed_guide_ids
    related_to_editions.where(type: 'DetailedGuide').pluck(:id)
  end

  def related_detailed_guide_content_ids
    published_related_detailed_guides.map(&:content_id)
  end

  # Ensure that we set related detailed guides without stomping on other related documents
  def related_detailed_guide_ids=(detailed_guide_ids)
    detailed_guide_ids        = Array.wrap(detailed_guide_ids).reject(&:blank?)
    other_related_documents   = self.related_documents.reject { |document| document.document_type == 'DetailedGuide' }
    detailed_guide_documents  = DetailedGuide.find(detailed_guide_ids).map {|guide| guide.document }

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

  def display_type
    "Detailed guide"
  end

  def display_type_key
    "detailed_guidance"
  end

  def search_format_types
    super + [DetailedGuide.search_format_type]
  end
  def self.search_format_type
    'detailed-guidance'
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

  def related_mainstream
    base_paths = []
    base_paths.push(related_mainstream_base_path)
    base_paths.push(additional_related_mainstream_base_path)
    base_paths.compact!

    if base_paths.any?
      Whitehall.publishing_api_v2_client
        .lookup_content_ids(base_paths: base_paths)
        .values
        .compact
    else
      []
    end
  end

  def government
    @government ||= Government.on_date(date_for_government) unless date_for_government.nil?
  end

private

  def date_for_government
    published_edition_date = first_public_at.try(:to_date)
    draft_edition_date = updated_at.try(:to_date)
    published_edition_date || draft_edition_date
  end

  def parse_base_path_from_related_mainstream_url(url)
    return nil if url.nil? || url.empty?
    parsed_url = URI.parse(url)
    url_is_invalid = !['gov.uk', 'www.gov.uk'].include?(parsed_url.host)
    return nil if url_is_invalid
    URI.parse(url).path
  end

  # Returns the published edition of any detailed guide documents that this edition is related to.
  def published_outbound_related_detailed_guides
    related_documents.published.where(document_type: 'DetailedGuide').map { |document| document.published_edition }.compact
  end

  # Returns the published editions that are related to this edition's document.
  def published_inbound_related_detailed_guides
    DetailedGuide.published.joins(:outbound_edition_relations).where(edition_relations: { document_id: document.id })
  end

  def related_mainstream_content_valid?
    if related_mainstream_content_url.present? && related_mainstream_content_title.blank?
      errors.add(:related_mainstream_content_title, "cannot be blank if a related URL is given")
    end
  end

  def additional_related_mainstream_content_valid?
    if additional_related_mainstream_content_url.present? && additional_related_mainstream_content_title.blank?
      errors.add(:additional_related_mainstream_content_title, "cannot be blank if an additional related URL is given")
    end
  end

  def self.format_name
    'detailed guidance'
  end
end
