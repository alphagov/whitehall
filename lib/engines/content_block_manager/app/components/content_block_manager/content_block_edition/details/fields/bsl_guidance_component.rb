class ContentBlockManager::ContentBlockEdition::Details::Fields::BSLGuidanceComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent
  def show_field
    field.nested_field("show")
  end

  def value_field
    field.nested_field("value")
  end

  def label_for(field_name)
    humanized_label(relative_key: field_name, root_object: "telephones.bsl_guidance")
  end
end
