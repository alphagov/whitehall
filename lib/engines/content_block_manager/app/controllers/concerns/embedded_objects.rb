module EmbeddedObjects
  extend ActiveSupport::Concern
  include ParamsPreprocessor

  def get_schema_and_subschema(block_type, object_type)
    schema = get_schema(block_type)
    subschema = get_subschema(schema, object_type)

    [schema, subschema]
  end

  def get_schema(block_type)
    ContentBlockManager::ContentBlock::Schema.find_by_block_type(block_type)
  end

  def get_subschema(schema, object_type)
    schema.subschema(object_type) or raise(ActionController::RoutingError, "Subschema for #{object_type} not found")
  end

  def object_params(subschema)
    processed_params.require("content_block/edition").permit(
      details: {
        subschema.block_type.to_s => subschema.permitted_params,
      },
    )
  end
end
