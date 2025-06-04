module ContentBlockManager::ContentBlock::SchemaHelper
  def grouped_subschemas(schema)
    schema.subschemas
           .select { |subschema| subschema.group.present? }
           .group_by(&:group)
  end

  def ungrouped_subschemas(schema)
    schema.subschemas.select { |subschema| subschema.group.blank? }
  end
end
