class ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
private

  def name_for_field(field)
    "#{name}[#{field.name}]"
  end

  def id_for_field(field)
    "#{id}_#{field.name}"
  end

  def value_for_field(field)
    value&.fetch(field.name, nil)
  end
end
