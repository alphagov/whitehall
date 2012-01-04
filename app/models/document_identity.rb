class DocumentIdentity < ActiveRecord::Base
  extend FriendlyId
  friendly_id :sluggable_string, use: :slugged

  has_many :documents
  has_many :document_relations
  has_one :published_document, class_name: 'Document', conditions: { state: 'published' }
  has_one :unpublished_document, class_name: 'Document', conditions: { state: ['draft', 'submitted', 'rejected'] }

  has_one :published_consultation_response, class_name: 'ConsultationResponse', foreign_key: :consultation_document_identity_id, conditions: { state: 'published' }
  has_one :latest_consultation_response, class_name: 'ConsultationResponse', foreign_key: :consultation_document_identity_id, conditions: 'NOT EXISTS (SELECT 1 from documents d2 where d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id)'

  has_one :latest_edition, class_name: 'Document', conditions: 'NOT EXISTS (SELECT 1 from documents d2 where d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id)'

  attr_accessor :sluggable_string

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def unpublished_edition
    documents.where("state IN (:draft_states)", draft_states: [:draft, :submitted, :rejected]).first
  end

  class << self
    def published
      joins(:published_document)
    end
  end
end