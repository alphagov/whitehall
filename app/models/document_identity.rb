class DocumentIdentity < ActiveRecord::Base
  include Whitehall::RandomKey

  has_many :documents
  has_one :published_document, class_name: 'Document', conditions: { state: 'published' }

  class << self
    def published
      joins(:published_document)
    end
  end
end