class NewsArticle < Announcement
  include Edition::Ministers
  include Edition::FactCheckable
end
