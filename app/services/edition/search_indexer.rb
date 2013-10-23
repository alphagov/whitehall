class Edition::SearchIndexer

  def self.edition_published(edition, options={})
    if edition.can_index_in_search?
      Searchable::Index.later(edition)

      if edition.allows_supporting_pages?
        edition.supporting_pages.each { |supporting_page| Searchable::Index.later(supporting_page) }
      end
    end
  end
end
