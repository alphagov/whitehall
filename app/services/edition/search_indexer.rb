class Edition::SearchIndexer
  attr_accessor :edition

  def self.edition_published(edition, options={})
    if edition.can_index_in_search?
      new(edition).index!
    end
  end

  def initialize(edition)
    @edition = edition
  end

  def index!
    Searchable::Index.later(edition)
    index_supporting_pages if edition.allows_supporting_pages?
    index_related_editions if edition.is_a?(Policy)
  end

  def index_supporting_pages
    edition.supporting_pages.each { |supporting_page| Searchable::Index.later(supporting_page) }
  end

  def index_related_editions
    PolicySearchIndexObserver::ReindexRelatedEditions.later(edition)
  end
end
