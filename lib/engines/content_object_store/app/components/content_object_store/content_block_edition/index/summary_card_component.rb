class ContentObjectStore::ContentBlockEdition::Index::SummaryCardComponent < ContentObjectStore::ContentBlockEdition::Show::SummaryListComponent
private

  def rows
    items.map do |item|
      {
        key: item[:field],
        value: item[:value],
      }
    end
  end

  def title
    content_block_edition.document.title
  end

  def summary_card_actions
    [
      {
        label: "View/edit",
        href: helpers.content_object_store.content_object_store_content_block_edition_path(content_block_edition),
      },
    ]
  end
end
