class DocumentIdentity < ActiveRecord::Base
  has_many :documents
  has_one :published_document, class_name: 'Document', conditions: { state: 'published' }

  class << self
    def published
      joins(:published_document)
    end

    def from_param(id)
      find_by_id(id)
    end
  end
end