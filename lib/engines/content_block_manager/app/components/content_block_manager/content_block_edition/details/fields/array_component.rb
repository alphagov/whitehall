class ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
private

  def label
    super.singularize
  end

  def value
    super || []
  end

  def items
    if value.count.positive?
      Array.new(value.count) do |index|
        {
          fields: render(component(index)),
          destroy_checkbox: destroy_checkbox(index),
        }
      end
    else
      [{ fields: render(component(0)) }]
    end
  end

  def empty
    render component(value.count.positive? ? value.count : 1)
  end

  def component(index)
    ContentBlockManager::ContentBlockEdition::Details::Fields::Array::ItemComponent.new(
      field_name: label,
      array_items: field.array_items,
      name_prefix: name,
      id_prefix: id,
      value: value,
      index: index,
      errors:,
      error_lookup_prefix: "details_#{id_suffix}",
    )
  end

  def destroy_checkbox(index)
    render("govuk_publishing_components/components/checkboxes", { name: "#{id}[#{index}][_destroy]", items: [{ label: "Delete", value: "1" }] })
  end

  def errors
    content_block_edition.errors
  end
end
