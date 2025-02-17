class ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent < ViewComponent::Base
  def initialize(content_block_edition:, object_type:, object_name:, is_editable: false, redirect_url: nil)
    @content_block_edition = content_block_edition
    @object_type = object_type
    @object_name = object_name
    @is_editable = is_editable
    @redirect_url = redirect_url
  end

private

  attr_reader :content_block_edition, :object_type, :object_name, :is_editable, :redirect_url

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
    if is_editable
      [
        {
          label: "Edit",
          href: helpers.content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
            content_block_edition,
            object_type:,
            object_name:,
            redirect_url:,
          ),
        },
      ]
    else
      []
    end
  end
end
