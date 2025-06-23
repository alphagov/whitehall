class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHoursComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent
private

  def label
    "Opening Hours"
  end

  def component(index)
    ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponent.new(
      name_prefix: name,
      id_prefix: id,
      value: value,
      index:,
      field:,
    )
  end
end
