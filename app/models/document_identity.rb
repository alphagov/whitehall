class DocumentIdentity < ActiveRecord::Base
  extend FriendlyId
  friendly_id :sluggable_string, use: :scoped, scope: :document_type

  has_many :documents, dependent: :destroy
  has_many :document_relations, dependent: :destroy
  has_one :published_document, class_name: 'Document', conditions: { state: 'published' }
  has_one :unpublished_document, class_name: 'Document', conditions: { state: ['draft', 'submitted', 'rejected'] }

  has_one :published_consultation_response, class_name: 'ConsultationResponse', foreign_key: :consultation_document_identity_id, conditions: { state: 'published' }
  has_one :latest_consultation_response, class_name: 'ConsultationResponse', foreign_key: :consultation_document_identity_id, conditions: "NOT EXISTS (SELECT 1 FROM documents d2 WHERE d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id AND d2.state <> 'deleted')"

  has_one :latest_edition, class_name: 'Document', conditions: "NOT EXISTS (SELECT 1 FROM documents d2 WHERE d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id AND d2.state <> 'deleted')"

  attr_accessor :sluggable_string

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def unpublished_edition
    documents.where("state IN (:draft_states)", draft_states: [:draft, :submitted, :rejected]).first
  end

  def editions_ever_published
    documents.where(state: [:published, :archived]).by_published_at
  end

  def update_slug_if_possible(new_title)
    unless published?
      self.sluggable_string = new_title
      save
    end
  end

  def set_document_type(document_type)
    self.document_type = document_type
  end

  def published?
    published_document.present?
  end

  class << self
    def published
      joins(:published_document)
    end
  end
end