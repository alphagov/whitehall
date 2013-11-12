module Edition::SupportingPages
  extend ActiveSupport::Concern

  def supporting_pages
    related_editions.where(type: 'SupportingPage')
  end

  # In the admin system we often want to see the latest active edition
  # for each document in a collection. This method returns the most
  # recent (as judged by the ID) draft or published edition for each
  # supporting page.
  def active_supporting_pages
    # Approach: Join editions to itself where the document IDs match
    # and the edition ID is smaller than another edition ID. The row
    # which has a null later edition is the most recent.
    supporting_pages.where(state: [:published, :draft]).joins(%(
      LEFT OUTER JOIN editions AS later_editions
      ON editions.document_id = later_editions.document_id
      AND editions.id < later_editions.id
    )).where(%(
      later_editions.document_id IS NULL
    ))
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
