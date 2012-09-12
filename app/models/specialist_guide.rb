class SpecialistGuide < Edition
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Topics
  include ::Attachable
  include Edition::FactCheckable

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.outbound_related_documents = @edition.outbound_related_documents
    end
  end

  has_many :outbound_edition_relations, foreign_key: :edition_id, dependent: :destroy, class_name: 'EditionRelation'
  has_many :outbound_related_documents, through: :outbound_edition_relations, source: :document
  has_many :latest_outbound_related_specialist_guides, through: :outbound_related_documents, source: :latest_edition, class_name: 'SpecialistGuide'
  has_many :published_outbound_related_specialist_guides, through: :outbound_related_documents, source: :published_edition, class_name: 'SpecialistGuide'

  has_many :inbound_edition_relations, through: :document, source: :edition_relations
  has_many :inbound_related_editions, through: :inbound_edition_relations, source: :edition
  has_many :inbound_related_documents, through: :inbound_related_editions, source: :document
  has_many :latest_inbound_related_specialist_guides, through: :inbound_related_documents, source: :latest_edition, class_name: 'SpecialistGuide'
  has_many :published_inbound_related_specialist_guides, through: :inbound_related_documents, source: :published_edition, class_name: 'SpecialistGuide'

  add_trait Trait

  validate :related_mainstream_content_valid?
  validate :additional_related_mainstream_content_valid?

  def related_specialist_guides
    (latest_outbound_related_specialist_guides + latest_inbound_related_specialist_guides).uniq
  end

  def published_related_specialist_guides
    (published_outbound_related_specialist_guides + published_inbound_related_specialist_guides).uniq
  end

  def can_have_summary?
    true
  end

  def allows_body_to_be_paginated?
    true
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

  private

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

  class << self
    def format_name
      'specialist guidance'
    end
  end
end
