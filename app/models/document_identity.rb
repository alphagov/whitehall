class DocumentIdentity < ActiveRecord::Base
  extend FriendlyId
  friendly_id :sluggable_string, use: :slugged

  has_many :documents
  has_one :published_document, class_name: 'Document', conditions: { state: 'published' }

  attr_accessor :sluggable_string

  class << self
    def published
      joins(:published_document)
    end
  end
end