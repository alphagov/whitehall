module ContentBlockManager
  module ContentBlock
    class Document < ApplicationRecord
      include Scopes::SearchableByKeyword
      include Scopes::SearchableByLeadOrganisation
      include Scopes::SearchableByUpdatedDate

      include SoftDeletable

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

      def embed_code(use_friendly_id: Flipflop.use_friendly_embed_codes?)
        "#{embed_code_prefix(use_friendly_id)}}}"
      end

      def embed_code_for_field(field_path, use_friendly_id: Flipflop.use_friendly_embed_codes?)
        "#{embed_code_prefix(use_friendly_id)}/#{field_path}}}"
      end

      def title
        @title ||= latest_edition&.title
      end

      def is_new_block?
        editions.count == 1
      end

      def has_newer_draft?
        latest_edition_id != editions.select(:id, :created_at).order(created_at: :asc).last.id
      end

      def latest_draft
        editions.where(state: :draft).order(created_at: :asc).last
      end

      def schema
        @schema ||= ContentBlockManager::ContentBlock::Schema.find_by_block_type(block_type)
      end

    private

      def embed_code_prefix(use_friendly_id)
        "{{embed:content_block_#{block_type}:#{use_friendly_id ? content_id_alias : content_id}"
      end
    end
  end
end
