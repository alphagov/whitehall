class NewsArticle < Document
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments
  include Document::Countries
end