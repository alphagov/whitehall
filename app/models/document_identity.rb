class DocumentIdentity < ActiveRecord::Base
  include Whitehall::RandomKey
  extend FriendlyId
  friendly_id :document_title, use: :slugged

  has_many :documents
  has_one :published_document, class_name: 'Document', conditions: { state: 'published' }

  def document_title
    documents.first.title if documents.any?
  end

  class << self
    def published
      joins(:published_document)
    end
  end
end