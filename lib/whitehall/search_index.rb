module Whitehall
  # Whitehall::SearchIndex.add indexes content asynchronously.
  # Whitehall::SearchIndex.for returns a class that indexes content synchronously.
  #
  class SearchIndex
    extend LockedDocumentConcern

    def self.add(instance)
      check_if_locked_document(edition: instance) if instance.is_a?(Edition)

      # Note We delay the search index job to ensure that any transactions
      # around publishing will have had time to complete. Specifically,
      # EditionPublishingWorker publishes scheduled editions in a transaction
      # and we want to ensure that transaction is complete before we attempt to
      # index the edition, otherwise the edition may still be in a "scheduled"
      # state, and SearchIndexAddWorker will not index a non-"published" edition.
      SearchIndexAddWorker.perform_in(10.seconds, instance.class.name, instance.id)
    end

    def self.delete(instance)
      SearchIndexDeleteWorker.perform_async(instance.search_index["link"], instance.rummager_index)
    end

    def self.for(type, options = {})
      path = {
        government: government_search_index_path,
        detailed_guides: detailed_search_index_path,
      }.fetch(type)
      indexer_class.new(rummager_host, path, { logger: Rails.logger }.merge(options))
    end

    def self.government_search_index_path
      "/government"
    end

    def self.detailed_search_index_path
      "/detailed"
    end

    def self.indexer_class
      if Rails.env.test?
        FakeRummageableIndex
      else
        Rummageable::Index
      end
    end

    def self.rummager_host
      Plek.find("search")
    end
  end
end
