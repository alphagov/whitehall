module ServiceListeners
  SearchIndexer = Struct.new(:edition) do

    def index!
      if edition.can_index_in_search?
        Searchable::Index.later(edition)
        index_supporting_pages if edition.allows_supporting_pages?
        index_related_editions if edition.is_a?(Policy)
      end
    end

    def index_supporting_pages
      edition.supporting_pages.each { |supporting_page| Searchable::Index.later(supporting_page) }
    end

    def index_related_editions
      PolicySearchIndexObserver::ReindexRelatedEditions.later(edition)
    end
  end
end
