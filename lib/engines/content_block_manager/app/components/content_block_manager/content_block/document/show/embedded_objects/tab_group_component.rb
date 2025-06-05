class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabGroupComponent < ViewComponent::Base
  def initialize(content_block_document:, subschemas:)
    @content_block_edition = content_block_document.latest_edition
    @subschemas = subschemas
  end

private

  attr_reader :content_block_edition, :subschemas

  def tabs
    subschemas.map do |subschema|
      tab_for_subschema(subschema)
    end
  end

  def tab_for_subschema(subschema)
    component = component_for_subschema(subschema)
    {
      id: component.id,
      label: component.label,
      content: render(component),
    }
  end

  def component_for_subschema(subschema)
    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemsComponent.new(
      content_block_edition:,
      subschema:,
      show_button: false,
    )
  end
end
