class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHoursComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent
private

  def show_opening_hours
    field.nested_field("show_opening_hours")
  end

  def opening_hours
    field.nested_field("opening_hours")
  end

  def label_for(field_name)
    humanized_label(relative_key: field_name, root_object: "telephones.opening_hours")
  end
end
