class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHoursComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent
private

  def label
    "Opening Hour"
  end

  def component(index)
    ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponent.new(
      name_prefix: name,
      id_prefix: id,
      value: value,
      index:,
      field:,
      errors:,
      can_be_deleted: can_be_deleted?(index),
    )
  end
end
