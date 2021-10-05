module TopicsHelper
  def classification_contents_breakdown(classification)
    capture do
      concat tag.span(pluralize(classification.published_detailed_guides.count, "published detailed guide"))
    end
  end

  def topic_grid_size_class(*edition_scopes)
    "grid-size-#{edition_scopes.compact.select(&:any?).length}"
  end
end
