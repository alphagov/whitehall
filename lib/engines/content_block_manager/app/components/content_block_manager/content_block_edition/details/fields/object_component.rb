class ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
  private

  def component_for_field(embedded_field)
    args = component_args(embedded_field).merge(
      enum: embedded_field.enum_values,
    )

    embedded_field.component_class.new(**args.compact)
  end

  def component_args(embedded_field)
    {
      content_block_edition:,
      field: embedded_field,
      value: value&.fetch(embedded_field.name, nil),
      parent_objects: [schema.id, embedded_field.parent_name],
    }
  end

  def schema
    @schema ||= field.schema
  end
end
