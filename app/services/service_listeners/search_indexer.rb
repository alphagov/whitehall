module ServiceListeners
  SearchIndexer = Struct.new(:edition) do
    def index!
      if edition.can_index_in_search?
        Searchable::Index.later(edition)
        index_related_editions if edition.is_a?(Policy)
      end
    end

    def remove!
      Searchable::Delete.later(edition)
      index_related_editions if edition.is_a?(Policy)
    end

  private
    def index_related_editions
      ReindexRelatedEditions.later(edition)
    end
  end
end
