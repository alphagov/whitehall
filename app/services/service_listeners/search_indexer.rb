module ServiceListeners
  SearchIndexer = Struct.new(:edition) do

    def index!
      if edition.can_index_in_search?
        Searchable::Index.later(edition)
        refresh_supporting_page_indexing if edition.allows_supporting_pages?
        index_related_editions if edition.is_a?(Policy)
      end
    end

    def remove!
      Searchable::Delete.later(edition)
      clear_supporting_page_indexing if edition.allows_supporting_pages?
      index_related_editions if edition.is_a?(Policy)
    end

  private

    def refresh_supporting_page_indexing
      if previous_edition = edition.previous_edition
        previous_edition.supporting_pages.each { |supporting_page| Searchable::Delete.later(supporting_page) }
      end
      edition.supporting_pages.each { |supporting_page| Searchable::Index.later(supporting_page) }
    end

    def clear_supporting_page_indexing
      edition.supporting_pages.each { |supporting_page| Searchable::Delete.later(supporting_page) }
    end

    def index_related_editions
      ReindexRelatedEditions.later(edition)
    end
  end
end
