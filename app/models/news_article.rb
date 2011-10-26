class NewsArticle < Document
  include Document::Topics
  include Document::Ministers
  include Document::FactCheckable
end