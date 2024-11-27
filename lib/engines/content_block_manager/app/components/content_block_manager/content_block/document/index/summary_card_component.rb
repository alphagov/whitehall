class ContentBlockManager::ContentBlock::Document::Index::SummaryCardComponent < ContentBlockManager::ContentBlock::Document::Show::SummaryListComponent
private

  def rows
    items.map do |item|
      {
        key: item[:field],
        value: item[:value],
        data: item[:data],
      }
    end
  end

  def items
    [
      title_item,
      *details_items,
      organisation_item,
      last_updated_item,
      (instructions_item if content_block_document.latest_edition.instructions_to_publishers.present?),
      embed_code_item,
    ].compact
  end

  def title
    content_block_document.title
  end

  def summary_card_actions
    [
      {
        label: "View",
        href: helpers.content_block_manager.content_block_manager_content_block_document_path(content_block_document),
      },
    ]
  end
end
