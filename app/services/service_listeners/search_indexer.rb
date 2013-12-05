module ServiceListeners
  SearchIndexer = Struct.new(:edition) do
    def index!
      if edition.can_index_in_search?
        Searchable::Index.later(edition)
      end
    end

    def remove!
      Searchable::Delete.later(edition)
    end
  end
end
