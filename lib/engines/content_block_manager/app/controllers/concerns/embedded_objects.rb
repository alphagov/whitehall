module EmbeddedObjects
  extend ActiveSupport::Concern

  def get_schema_and_subschema(block_type, object_type)
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(block_type)
    @subschema = @schema.subschema(object_type)

    render "admin/errors/not_found", status: :not_found unless @subschema
  end

  def object_params(subschema)
    params.require("content_block/edition").permit(
      details: {
        block_attributes: {
          subschema.block_type.to_s => subschema.permitted_params,
        },
      },
    )
  end
end
