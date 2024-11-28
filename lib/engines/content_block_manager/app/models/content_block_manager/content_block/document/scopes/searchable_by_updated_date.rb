module ContentBlockManager
  module ContentBlock::Document::Scopes::SearchableByUpdatedDate
    extend ActiveSupport::Concern

    included do
      scope :from_date, ->(date) { where("content_block_documents.updated_at >= ?", date) }
      scope :to_date, ->(date) { where("content_block_documents.updated_at <= ?", date) }
    end
  end
end
