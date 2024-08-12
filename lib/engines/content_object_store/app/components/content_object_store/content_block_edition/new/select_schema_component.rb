class ContentObjectStore::ContentBlockEdition::New::SelectSchemaComponent < ViewComponent::Base
  def initialize(schemas:, heading:, heading_caption:, error_message:)
    @heading = heading
    @heading_caption = heading_caption
    @error_message = error_message
    @schemas = schemas
  end

private

  attr_reader :heading, :heading_caption, :error_message

  def items
    @schemas.map do |schema|
      {
        value: schema.parameter,
        text: schema.name,
      }
    end
  end
end
