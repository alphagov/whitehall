# A form object to reuse the same form partial for creating and editing a content block edition
# - Creating an object requires dynamic attributes from a schema
# # - Editing an object requires attributes from the object itself
class ContentObjectStore::ContentBlock::EditionForm
  include ContentObjectStore::Engine.routes.url_helpers

  attr_reader :content_block_edition, :schema, :url

  def initialize(content_block_edition:, schema:)
    @content_block_edition = content_block_edition
    @schema = schema
  end

  class Create < ContentObjectStore::ContentBlock::EditionForm
    def url
      content_object_store_content_block_editions_path
    end

    def attributes
      @schema.fields.each_with_object({}) do |field, hash|
        hash[field] = nil
        hash
      end
    end

    def back_path
      content_object_store_content_block_documents_path
    end
  end

  class Update < ContentObjectStore::ContentBlock::EditionForm
    def url
      review_links_content_object_store_content_block_edition_path(id: @content_block_edition.id)
    end

    def attributes
      @content_block_edition.details
    end

    def back_path
      content_object_store_content_block_document_path(@content_block_edition.document)
    end
  end
end
