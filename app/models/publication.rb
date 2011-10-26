class Publication < Document
  include Document::Topics
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments

  belongs_to :attachment
end