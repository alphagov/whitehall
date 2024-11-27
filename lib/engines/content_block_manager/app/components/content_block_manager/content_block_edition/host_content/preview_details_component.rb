class ContentBlockManager::ContentBlockEdition::HostContent::PreviewDetailsComponent < ViewComponent::Base
  def initialize(content_block_edition:, preview_content:)
    @content_block_edition = content_block_edition
    @preview_content = preview_content
  end

private

  def list_items
    [*details_items, instances_item]
  end

  def details_items
    @content_block_edition.details.map do |key, value|
      { key: key.humanize, value: }
    end
  end

  def instances_item
    { key: "Instances", value: @preview_content.instances_count }
  end
end
