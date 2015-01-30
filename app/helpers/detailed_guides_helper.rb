module DetailedGuidesHelper
  def has_more_like_this?
    @categories.any? or @document.part_of_published_collection? or @document.published_related_detailed_guides.any?
  end
end
