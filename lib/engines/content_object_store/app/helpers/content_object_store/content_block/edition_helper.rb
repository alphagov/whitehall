module ContentObjectStore::ContentBlock::EditionHelper
  def link_to_new_block_type(schema)
    link_to schema.name, content_object_store.new_content_object_store_content_block_edition_path(block_type: schema.parameter)
  end
end
