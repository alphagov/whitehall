class NewsArticle < Document
  include Document::Topics
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments
  include Document::Countries
end