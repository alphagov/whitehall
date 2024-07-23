# A form object to reuse the same form partial for creating and editing a content block edition
# - Creating an object requires dynamic attributes from a schema
# - Editing an object requires attributes from the object itself
class ContentObjectStore::ContentBlockEditionForm
  include ContentObjectStore::Engine.routes.url_helpers

  attr_reader :content_block_edition, :schema, :attributes, :back_path

  def initialize(content_block_edition:, schema:, attributes:, back_path:)
    @content_block_edition = content_block_edition
    @schema = schema
    @attributes = attributes
    @back_path = back_path
  end
end
