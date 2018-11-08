module Whitehall::DocumentFilter
  class SearchResult
    ACCESSORS = %w{title description indexable_content attachments
                   format content_id search_format_types
                   relevant_to_local_government display_type id document_collections}.freeze
    ACCESSORS.each do |attribute_name|
      define_method attribute_name.to_sym do
        @doc[attribute_name.to_s]
      end
    end

    def initialize(doc)
      @doc = doc
    end

    def type
      format
    end

    def search_government_name
      @doc['government_name']
    end

    def historic?
      @doc['is_historic']
    end

    def public_timestamp
      @doc['public_timestamp'].nil? ? Time.zone.now : Time.zone.parse(@doc['public_timestamp'])
    end

    def part_of_published_collection?
      published_document_collections.any?
    end

    def organisations
      @doc.fetch('organisations', []).map { |organisation| fetch_from_cache(:organisation, organisation.fetch('slug', nil)) }.compact
    end

    def topics
      @doc.fetch('topics', []).map { |topic| fetch_from_cache(:topic, topic.fetch('slug', nil)) }.compact
    end

    def published_document_collections
      @doc.fetch('document_collections', []).map { |document_collection| fetch_from_cache(:document_collection, document_collection.fetch('slug', nil)) }.compact
    end

    def operational_field
      fetch_from_cache(:operational_field, @doc['operational_field'])
    end

    def link
      @doc.fetch('link', [])
    end

  private

    def fetch_from_cache(type, slug)
      FetchFromCacheService.new(type, slug).fetch
    end
  end
end
