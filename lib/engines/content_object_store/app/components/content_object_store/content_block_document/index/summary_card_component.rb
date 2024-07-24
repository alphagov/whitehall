class ContentObjectStore::ContentBlockDocument::Index::SummaryCardComponent < ContentObjectStore::ContentBlockDocument::Show::SummaryListComponent
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
    content_block_document.title
  end

  def summary_card_actions
    [
      {
        label: "View/edit",
        href: helpers.content_object_store.content_object_store_content_block_document_path(content_block_document),
      },
    ]
  end
end
