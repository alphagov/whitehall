module ServiceListeners
  SearchIndexer = Struct.new(:edition) do
    def index!
      if edition.can_index_in_search?
        if edition.is_a?(Publication) && edition.has_changed_publication_type?
          Whitehall::SearchIndex.delete(edition.previous_edition)
        end

        Whitehall::SearchIndex.add(edition)
        reindex_collection_documents
      elsif edition.previous_edition&.can_index_in_search?
        # If the previous edition was indexed but the current edition cannot be, we must delete the previous edition from the index
        Whitehall::SearchIndex.delete(edition.previous_edition)
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
        edition.groups.flat_map(&:published_editions).each do |collected_edition|
          Whitehall::SearchIndex.add(collected_edition)
        end
      end
    end
  end
end
