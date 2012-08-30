class NewsArticle < Announcement
  include Edition::Ministers
  include Edition::FactCheckable

  def lead_image
    images.first
  end
end
