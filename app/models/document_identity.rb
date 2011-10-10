class DocumentIdentity < ActiveRecord::Base
  has_many :documents
  has_one :published_document, class_name: 'Document', conditions: { state: 'published' }

  def self.published
    joins(:published_document)
  end
end