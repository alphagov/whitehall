class Publication < Document
  include Document::Topics
  include Document::Ministers
  include Document::FactCheckable

  belongs_to :attachment
end