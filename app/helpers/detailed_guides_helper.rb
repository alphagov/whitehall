module DetailedGuidesHelper
  def has_more_like_this?
    @document.part_of_published_collection? || @document.published_related_detailed_guides.any?
  end
end
