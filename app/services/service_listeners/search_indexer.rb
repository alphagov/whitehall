module ServiceListeners
  SearchIndexer = Struct.new(:edition) do
    def index!
      if edition.can_index_in_search?
        Searchable::Index.later(edition)
        reindex_collection_documents
      end
    end

    def remove!
      Searchable::Delete.later(edition)
      reindex_collection_documents
    end

  private
    def reindex_collection_documents
      if edition.is_a?(DocumentCollection)
        edition.published_editions.each do |collected_edition|
          Searchable::Index.later(collected_edition)
        end
      end
    end
  end
end
