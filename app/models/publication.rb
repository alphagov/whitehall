class Publication < Document
  include Document::Topics
  include Document::Ministers

  belongs_to :attachment
end