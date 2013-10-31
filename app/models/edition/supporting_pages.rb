module Edition::SupportingPages
  extend ActiveSupport::Concern

  def supporting_pages
    related_editions.where(type: 'SupportingPage')
  end

  def allows_supporting_pages?
    true
  end

  def has_supporting_pages?
    supporting_pages.any?
  end
end
