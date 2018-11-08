module Whitehall::DocumentFilter
  class AdvancedSearchResult
    ACCESSORS = %w{title description indexable_content attachments
                   format display_type link id search_format_types
                   relevant_to_local_government}.freeze
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
      Time.zone.parse(@doc['public_timestamp'])
    end

    def part_of_published_collection?
      published_document_collections.any?
    end

    def organisations
      @doc.fetch('organisations', []).map { |slug| fetch_from_cache(:organisation, slug) }.compact
    end

    def topics
      @doc.fetch('topics', []).map { |slug| fetch_from_cache(:topic, slug) }.compact
    end

    def published_document_collections
      @doc.fetch('document_collections', []).map { |slug| fetch_from_cache(:document_collection, slug) }.compact
    end

    def operational_field
      fetch_from_cache(:operational_field, @doc['operational_field'])
    end

  private

    def fetch_from_cache(type, slug)
      FetchFromCacheService.new(type, slug).fetch
    end
  end
end
