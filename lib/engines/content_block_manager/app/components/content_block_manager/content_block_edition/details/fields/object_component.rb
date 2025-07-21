class ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
private

  def name_for_field(field)
    "#{name}[#{field.name}]"
  end

  def id_for_field(field)
    "#{id}_#{field.name}"
  end

  def errors_for_field(field)
    errors_for(content_block_edition.errors, "details_#{id_suffix}_#{field.name}".to_sym)
  end

  def value_for_field(field)
    value&.fetch(field.name, nil)
  end
end
