class SupportingPageSearchIndexObserver < ActiveRecord::Observer
  observe :policy # observe :document doesn't work

  def after_publish(document)
    document.supporting_pages.each(&:update_in_search_index)
  end

  def after_archive(document)
    document.supporting_pages.each(&:remove_from_search_index)
  end
end
