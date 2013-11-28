module Edition::SupportingPages
  extend ActiveSupport::Concern

  def supporting_pages
    related_editions.where(type: 'SupportingPage')
  end

  # In the admin system we often want to see the latest active edition
  # for each document in a collection. This method returns the most
  # recent (as judged by the ID) for each supporting page.
  def active_supporting_pages
    supporting_pages.latest_edition
  end

  def published_supporting_pages
    supporting_pages.published
  end

  def archived_supporting_pages
    supporting_pages.archived
  end

  def allows_supporting_pages?
    true
  end

  def has_active_supporting_pages?
    active_supporting_pages.any?
  end

  def has_published_supporting_pages?
    published_supporting_pages.any?
  end

  def has_visible_supporting_page?(supporting_page)
    published_supporting_pages.include?(supporting_page) ||
      archived_supporting_pages.include?(supporting_page)
  end
end
