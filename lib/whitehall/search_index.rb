module Whitehall
  class SearchIndex
    def self.for(type)
      method = {
        government: :government_search_index_path,
        detailed_guides: :detailed_guidance_search_index_path
      }.fetch(type)
      path = Whitehall.send(method)
      indexer_class.new(rummager_host, path, logger: Rails.logger)
    end

    def self.indexer_class
      if ENV.has_key?('RUMMAGER_HOST') || Rails.env.production?
        Rummageable::Index
      else
        FakeRummageableIndex
      end
    end

    def self.rummager_host
      ENV.fetch('RUMMAGER_HOST', Plek.current.find('search'))
    end

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
      SearchIndexDeleteWorker.perform_async(instance.search_index['link'], instance.rummager_index)
    end
  end

  class FakeRummageableIndex < Rummageable::Index
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

    def make_request(method, *args)
      raise RuntimeError.new("Use the in memory index (rather than rummager) in tests")
    end

  private
      def store
        self.class.store
      end
  end
end
