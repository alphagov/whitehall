module ContentBlockManager
  module ContentBlock::Document::Scopes::SearchableByUpdatedDate
    extend ActiveSupport::Concern

    included do
      scope :latest_edition, -> { joins(:editions).where("content_block_documents.latest_edition_id = content_block_editions.id") }
      scope :from_date, ->(date) { latest_edition.where("content_block_editions.updated_at >= ?", date) }
      scope :to_date, ->(date) { latest_edition.where("content_block_editions.updated_at <= ?", date) }
    end
  end
end
