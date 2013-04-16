class PolicySearchIndexObserver < ActiveRecord::Observer
  observe :policy

  def after_publish(policy)
    policy.published_related_editions.each(&:update_in_search_index)
  end

  def after_unpublish(policy)
    policy.published_related_editions.each(&:update_in_search_index)
  end
end
