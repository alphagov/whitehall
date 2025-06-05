class ContentBlockManager::ContentBlock::Document::EmbeddedObjects::New::SelectSubschemaComponent < ViewComponent::Base
  def initialize(schemas:, heading:, heading_caption:, error_message:)
    @schemas = schemas
    @heading = heading
    @heading_caption = heading_caption
    @error_message = error_message
  end

private

  attr_reader :heading, :heading_caption, :error_message

  def items
    @schemas.map do |schema|
      {
        value: schema.id,
        text: schema.name.singularize,
      }
    end
  end
end
