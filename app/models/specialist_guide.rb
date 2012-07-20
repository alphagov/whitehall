class SpecialistGuide < Edition
  include Edition::Topics
  include Edition::Attachable
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

  def related_specialist_guides
    (latest_outbound_related_specialist_guides + latest_inbound_related_specialist_guides).uniq
  end

  def published_related_specialist_guides
    (published_outbound_related_specialist_guides + published_inbound_related_specialist_guides).uniq
  end

  def has_summary?
    true
  end

  def allows_body_to_be_paginated?
    true
  end
end
