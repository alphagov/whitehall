require 'whitehall/document_filter/filterer'
module Whitehall
  module NotQuiteAsFakeSearch
    def self.stop_faking_it_quite_so_much!
      store = Whitehall::NotQuiteAsFakeSearch::Store.new
      SearchIndex.indexer_class.store = store
      Whitehall.government_search_client = Whitehall::NotQuiteAsFakeSearch::GdsApiRummager.new(
        Whitehall.government_search_index_path, store)
      Whitehall.search_backend = Whitehall::DocumentFilter::Rummager
    end

    def self.start_faking_it_again!
      SearchIndex.indexer_class.store = nil
    end

    class GdsApiRummager

      def initialize(index_name, store, field_mappings = nil)
        @index_name = index_name
        @field_mappings = field_mappings || default_field_mappings
        @store = store
      end

      def search(*args)
        raise "Not implemented"
      end

      def autocomplete(*args)
        raise "Not implemented"
      end

      def advanced_search(params)
        params = params.stringify_keys
        raise "Pagination params are required." if params["per_page"].nil? || params["page"].nil?

        order     = params.delete("order") || { public_timestamp: "desc" }
        keywords  = params.delete("keywords")
        per_page  = params.delete("per_page").to_i
        page      = params.delete("page").to_i

        apply_filters(keywords, params, order, per_page, page)
      end

    private
      def default_field_mappings
        {
          simple: %w{
            id
            title
            description
            indexable_content
            display_type
            section
            subsection
            subsubsection
            link
            organisations
            people
            topics
            topical_events
            search_format_types
            world_locations
            document_series
          },
          date: %w{public_timestamp},
          boolean: %w{relevant_to_local_government}
        }
      end

      def field_type(field_name)
        @field_mappings.keys.find do |type|
          @field_mappings[type].include?(field_name)
        end
      end

      def apply_filters(keywords, params, order, per_page, page)
        results = @store.index(@index_name).values
        results = filter_by_keywords(keywords, results) unless keywords.blank?
        results = params.keys.inject(results) do |results, field_name|
          case field_type(field_name)
          when :date
            filter_by_date_field(field_name, params[field_name], results)
          when :boolean
            filter_by_boolean_field(field_name, params[field_name], results)
          when :simple
            filter_by_simple_field(field_name, params[field_name], results)
          else
            raise GdsApi::Rummager::SearchServiceError, "cannot filter by field '#{field_name}', its type is not known"
          end
        end
        if order && order.any?
          results = Ordering.new(order).sort(results)
        end
        {
          "total" => results.count,
          "results" => paginate(results, per_page, page)
        }
      end

      def paginate(results, per_page, page)
        from = (page - 1) * per_page
        to = from + per_page
        results[from...to]
      end

      class Ordering
        def initialize(ordering)
          @ordering = ordering.stringify_keys
          validate_ordering!
        end

        def compare(left, right)
          @ordering.map do |field_name, direction|
            if direction == "asc"
              left.fetch(field_name) <=> right.fetch(field_name)
            else
              right.fetch(field_name) <=> left.fetch(field_name)
            end
          end.detect { |res| res != 0 } || 0
        end

        def sort(documents)
          documents.sort {|l, r| compare(l,r)}
        end

        def validate_ordering!
          @ordering.find do |field_name, direction|
            if ! %w{asc desc}.include?(direction)
              raise GdsApi::Rummager::SearchServiceError, "bad search direction #{direction} for #{field_name} (expected 'asc' or 'desc')"
            end
          end
        end
      end

      def filter_by_keywords(keywords, document_hashes)
        keywords_regexp = /(#{keywords.split(/\s+/).map { |k| Regexp.escape(k) }.join('|')})/
        document_hashes.select do |document_hash|
          %w{title indexable_content description}.any? {|field| document_hash[field] =~ keywords_regexp}
        end
      end

      def filter_by_boolean_field(field, desired_field_value, document_hashes)
        desired_boolean =
          if desired_field_value =~ /\A(true|1)\Z/
            true
          elsif desired_field_value =~ /\A(false|0)\Z/
            false
          else
            raise GdsApi::Rummager::SearchServiceError, "bad boolean value #{desired_field_value}"
          end

        document_hashes.select { |document_hash| document_hash[field] == desired_boolean }
      end

      def filter_by_simple_field(field, desired_field_values, document_hashes)
        document_hashes.select { |document_hash| ([*desired_field_values] & document_hash.fetch(field, [])).any? }
      end

      def filter_by_date_field(field, date_filter_hash, document_hashes)
        date_filter_hash = ActiveSupport::HashWithIndifferentAccess.new(date_filter_hash)
        date_filter_hash.keys.each do |k|
          raise GdsApi::Rummager::SearchServiceError, "Invalid date #{date_filter_hash[k]}" unless valid_date?(date_filter_hash[k])
        end
        date_filter_hash.each do |date_type, date|
          document_hashes.select! do |document_hash|
            if date_type == "from"
              document_hash[field] && Time.zone.parse(document_hash[field]) >= date
            elsif date_type == "to"
              document_hash[field] && Time.zone.parse(document_hash[field]) <= date
            else
              true
            end
          end
        end
        document_hashes
      end

      def valid_date?(date_value)
        date_value =~ /\A[0-9]{4}-[0-9]{2}-[0-9]{2}\Z/
      end
    end

    class Store
      def initialize
        @indexes = {}
      end

      def add(documents, index_name)
        docs = documents.is_a?(Hash) ? [documents] : documents
        docs.each do |document|
          document = normalize(document)
          index = self.index(index_name)
          index[document['link']] = document
        end
      end

      def delete(link, index_name)
        index = self.index(index_name)
        index.delete(link)
      end

      def index(index_name)
        initialize_index(index_name)
        @indexes[index_name]
      end

      def initialize_index(index_name)
        @indexes[index_name] ||= {}
      end

    private
      def normalize(document)
        document = document.stringify_keys
        document.each_with_object({}) do |(k,v), memo|
          memo[k] = case v
          when String, Array, Fixnum, TrueClass, FalseClass then v
          else v.to_s
          end
        end
      end
    end
  end
end
