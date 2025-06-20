class ContentBlockManager::ContentBlockEdition::Workflow::GroupComponent < ViewComponent::Base
  def initialize(content_block_edition:, subschemas:)
    @content_block_edition = content_block_edition
    @subschemas = subschemas
  end

private

  attr_reader :content_block_edition, :subschemas

  def tabs
    subschemas.sort_by(&:group_order).map { |subschema|
      tab_for_subschema(subschema)
    }.compact
  end

  def tab_for_subschema(subschema)
    items = items_for_subschema(subschema)
    if items.any?
      {
        id: subschema.id,
        label: tab_label(subschema, items),
        content: content_for_tab(subschema, items),
      }
    end
  end

  def tab_label(subschema, items)
    "#{subschema.name.titleize} (#{items.values.count})"
  end

  def content_for_tab(subschema, items)
    render ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.with_collection(
      items.keys,
      content_block_edition: content_block_edition,
      object_type: subschema.block_type,
      redirect_url: request.fullpath,
    )
  end

  def items_for_subschema(subschema)
    content_block_edition.details.fetch(subschema.block_type, {})
  end
end
