class Publication < Document
  include Document::Topics

  belongs_to :attachment
end