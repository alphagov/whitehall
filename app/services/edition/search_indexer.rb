class Edition::SearchIndexer

  def self.edition_published(edition, options={})
    Searchable::Index.later(edition) if edition.can_index_in_search?
  end
end
