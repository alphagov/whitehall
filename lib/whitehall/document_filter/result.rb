module Whitehall::DocumentFilter
  class Result
    ACCESSORS = %w{title description indexable_content attachments
      format display_type link id search_format_types
      relevant_to_local_government presentation_format
      humanized_format}
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
      Rails.cache.fetch("#{type}-#{slug}", namespace: "results", expires_in: 30.minutes, race_condition_ttl: 1.second) do
        case type
        when :organisation
          Organisation.includes(:translations).find_by_slug(slug)
        when :topic
          Classification.find_by_slug(slug)
        when :document_collection
          # Don't fall over if index refers a document which has had it's slug changed.
          Document.find_by_slug(slug).try(:published_edition)
        when :operational_field
          OperationalField.find_by_slug(slug)
        else
          raise "Can't fetch '#{type}' -- unknown type"
        end
      end
    end

  end
end
