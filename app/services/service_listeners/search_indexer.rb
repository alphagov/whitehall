module ServiceListeners
  SearchIndexer = Struct.new(:edition) do
    def index!
      if edition.can_index_in_search?
        Whitehall::SearchIndex.add(edition)
        reindex_collection_documents
      end
    end

    def remove!
      Whitehall::SearchIndex.delete(edition)
      reindex_collection_documents
    end

  private
    def reindex_collection_documents
      if edition.is_a?(DocumentCollection)
        edition.published_editions.each do |collected_edition|
          Whitehall::SearchIndex.add(collected_edition)
        end
      end
    end
  end
end
