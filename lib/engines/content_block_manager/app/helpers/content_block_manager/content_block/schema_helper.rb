module ContentBlockManager::ContentBlock::SchemaHelper
  def grouped_subschemas(schema)
    schema.subschemas
           .select { |subschema| subschema.group.present? }
           .group_by(&:group)
  end

  def ungrouped_subschemas(schema)
    schema.subschemas.select { |subschema| subschema.group.blank? }
  end

  def redirect_url_for_subschema(subschema, content_block_edition)
    step = subschema.group.present? ? "#{Workflow::Step::GROUP_PREFIX}#{subschema.group}" : "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}"
    content_block_manager.content_block_manager_content_block_workflow_path(content_block_edition, step:)
  end
end
