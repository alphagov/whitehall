module TopicsHelper
  def classification_contents_breakdown(classification)
    capture do
      concat tag.span(pluralize(classification.published_detailed_guides.count, "published detailed guide"))
    end
  end
end
