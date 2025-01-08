module ContentBlockManager
  module ContentBlock
    class Document < ApplicationRecord
      include Scopes::SearchableByKeyword
      include Scopes::SearchableByLeadOrganisation
      include Scopes::SearchableByUpdatedDate

      extend FriendlyId
      friendly_id :sluggable_string, use: :slugged, slug_column: :content_id_alias, routes: :default

      has_many :editions,
               -> { order(created_at: :asc, id: :asc) },
               inverse_of: :document

      enum :block_type, ContentBlockManager::ContentBlock::Schema.valid_schemas.index_with(&:to_s)
      attr_readonly :block_type

      validates :block_type, :sluggable_string, presence: true

      has_one :latest_edition,
              -> { joins(:document).where("content_block_documents.latest_edition_id = content_block_editions.id") },
              class_name: "ContentBlockManager::ContentBlock::Edition",
              inverse_of: :document

      has_many :versions, through: :editions, source: :versions

      scope :live, -> { where.not(latest_edition_id: nil) }

      def embed_code
        "{{embed:content_block_#{block_type}:#{content_id}}}"
      end

      def title
        @title ||= latest_edition&.title
      end
    end
  end
end
