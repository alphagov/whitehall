class TagDetailsSerializer < ActiveModel::Serializer
  attributes :browse_pages, :policies, :topics

  def browse_pages
    []
  end

  def policies
    return [] unless object.can_be_related_to_policies?
    object.policies.map(&:slug)
  end

  def topics
    [object.primary_specialist_sector_tag].compact +
      object.secondary_specialist_sector_tags
  end
end
