class DocumentIdentity < ActiveRecord::Base
  extend FriendlyId
  friendly_id :sluggable_string, use: :slugged

  has_many :documents
  has_one :published_document, class_name: 'Document', conditions: { state: 'published' }

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