module Whitehall
  # Whitehall::SearchIndex.add indexes content asynchronously.
  # Whitehall::SearchIndex.for returns a class that indexes content synchronously.
  #
  class SearchIndex
    def self.add(instance)
      # Note We delay the search index job to ensure that any transactions
      # around publishing will have had time to complete. Specifically,
      # EditionPublishingWorker publishes scheduled editions in a transaction
      # and we want to ensure that transaction is complete before we attempt to
      # index the edition, otherwise the edition may still be in a "scheduled"
      # state, and SearchIndexAddWorker will not index a non-"published" edition.
      SearchIndexAddWorker.perform_in(10.seconds, instance.class.name, instance.id)
    end

    def self.delete(instance)
      SearchIndexDeleteWorker.perform_async(instance.search_index["link"], instance.search_api_index.to_s)
    end

    def self.for(type, options = {})
      path = {
        government: government_search_index_path,
      }.fetch(type)
      indexer_class.new(search_api_host, path, { logger: Rails.logger }.merge(options))
    end

    def self.government_search_index_path
      "/government"
    end

    def self.indexer_class
      if Rails.env.test?
        FakeSearchableIndex
      else
        Searchable::Index
      end
    end

    def self.search_api_host
      Plek.find("search-api")
    end
  end

  unless defined?(FakeSearchableIndex)
    class FakeSearchableIndex < Searchable::Index
      class << self
        attr_accessor :store
      end
      @store = nil

      def initialize(url, name, options = {})
        super
        @index_name = name
      end

      def add(entry)
        add_batch([entry])
      end

      def add_batch(entries)
        store.add(entries, @index_name) if store.present?
      end

      def delete(link)
        store.delete(link, @index_name) if store.present?
      end

      def make_request(_method, *_args)
        raise "Use the in memory index (rather than search_api) in tests"
      end

    private

      def store
        self.class.store
      end
    end
  end
end
