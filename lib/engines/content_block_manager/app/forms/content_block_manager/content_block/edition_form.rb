# A form object to reuse the same form partial for creating and editing a content block edition
# - Creating an object requires dynamic attributes from a schema
# # - Editing an object requires attributes from the object itself
class ContentBlockManager::ContentBlock::EditionForm
  include ContentBlockManager::Engine.routes.url_helpers

  attr_reader :content_block_edition, :schema

  def self.for(content_block_edition:, schema:)
    content_block_edition.document&.latest_edition_id ? Update.new(content_block_edition:, schema:) : Create.new(content_block_edition:, schema:)
  end

  def initialize(content_block_edition:, schema:)
    @content_block_edition = content_block_edition
    @schema = schema
  end

  def attributes
    @schema.fields.each_with_object({}) do |field, hash|
      hash[field] = nil
      hash
    end
  end

  class Create < ContentBlockManager::ContentBlock::EditionForm
    def title
      I18n.t("content_block_edition.create.title", block_type: schema.name.downcase)
    end

    def url
      content_block_manager_content_block_editions_path
    end

    def back_path
      new_content_block_manager_content_block_document_path
    end
  end

  class Update < ContentBlockManager::ContentBlock::EditionForm
    def title
      I18n.t("content_block_edition.update.title", block_type: schema.name.downcase)
    end

    def url
      content_block_manager_content_block_document_editions_path(document_id: @content_block_edition.document.id)
    end

    def back_path
      content_block_manager_content_block_document_path(@content_block_edition.document)
    end
  end
end
