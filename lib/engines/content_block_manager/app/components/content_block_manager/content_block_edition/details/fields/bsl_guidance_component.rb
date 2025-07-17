class ContentBlockManager::ContentBlockEdition::Details::Fields::BslGuidanceComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent
  def show_field
    field.nested_field("show")
  end

  def value_field
    field.nested_field("value")
  end
end
