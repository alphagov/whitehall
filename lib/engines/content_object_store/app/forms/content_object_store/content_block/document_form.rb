class ContentObjectStore::ContentBlock::DocumentForm
  include ContentObjectStore::Engine.routes.url_helpers

  attr_reader :schema, :content_block_edition

  def initialize(schema:, content_block_edition: ContentObjectStore::ContentBlock::Edition.new)
    @schema = schema
    @content_block_edition = content_block_edition
  end

  def url
    content_object_store_content_block_documents_path(block_type: schema.block_type)
  end

  def attributes
    schema.fields.each_with_object({}) do |field, hash|
      hash[field] = nil
      hash
    end
  end

  def back_path
    content_object_store_content_block_documents_path
  end
end
