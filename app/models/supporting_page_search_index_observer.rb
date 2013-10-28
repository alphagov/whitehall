class SupportingPageSearchIndexObserver < ActiveRecord::Observer
  observe :policy # observe :edition doesn't work

  def after_unpublish(edition)
    edition.supporting_pages.each(&:remove_from_search_index)
  end

  def after_supersede(edition)
    edition.supporting_pages.each(&:remove_from_search_index)
  end
end
