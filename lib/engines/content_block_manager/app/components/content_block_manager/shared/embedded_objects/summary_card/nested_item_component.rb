class ContentBlockManager::Shared::EmbeddedObjects::SummaryCard::NestedItemComponent < ViewComponent::Base
  with_collection_parameter :nested_items

  def initialize(nested_items:, title:, nested_items_counter: nil)
    @nested_items = nested_items
    @title = title
    @nested_items_counter = nested_items_counter
  end

private

  attr_reader :nested_items, :nested_items_counter

  def title
    if @nested_items_counter
      "#{@title} #{@nested_items_counter + 1}"
    else
      @title
    end
  end

  def rows
    nested_items.map do |key, value|
      {
        key: key.titleize,
        value:,
      }
    end
  end
end
