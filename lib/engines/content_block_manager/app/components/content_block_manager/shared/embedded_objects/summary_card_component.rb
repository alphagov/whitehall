class ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent < ViewComponent::Base
  def initialize(content_block_edition:, object_type:, object_name:, show_edit_action: false)
    @content_block_edition = content_block_edition
    @object_type = object_type
    @object_name = object_name
    @show_edit_action = show_edit_action
  end

private

  attr_reader :content_block_edition, :object_type, :object_name, :show_edit_action

  def title
    "#{object_type.titleize.singularize} details"
  end

  def rows
    object.keys.map do |key|
      {
        key: key.titleize,
        value: object[key],
      }
    end
  end

  def object
    content_block_edition.details.dig(object_type, object_name)
  end

  def summary_card_actions
    if show_edit_action
      [
        {
          label: "Edit",
          href: helpers.content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
            content_block_edition,
            object_type:,
            object_name:,
          ),
        },
      ]
    else
      []
    end
  end
end
