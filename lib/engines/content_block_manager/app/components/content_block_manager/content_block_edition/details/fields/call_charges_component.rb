class ContentBlockManager::ContentBlockEdition::Details::Fields::CallChargesComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent
  def show_call_charges_info_url
    field.nested_field("show_call_charges_info_url")
  end

  def call_charges_info_url
    field.nested_field("call_charges_info_url")
  end

  def label
    field.nested_field("label")
  end

  def label_for(field_name)
    humanized_label(relative_key: field_name, root_object: "telephones.call_charges")
  end
end
