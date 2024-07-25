class ContentObjectStore::ContentBlockDocument::Show::SummaryListComponent < ViewComponent::Base
  def initialize(content_block_document:)
    @content_block_document = content_block_document
  end

private

  attr_reader :content_block_document

  def items
    [title_item].concat(details_items).concat([creator_item])
  end

  def title_item
    {
      field: "Title",
      value: content_block_document.title,
      edit: edit_action,
    }
  end

  def details_items
    content_block_document.latest_edition.details.map do |key, value|
      {
        field: key.humanize,
        value:,
        edit: edit_action,
      }
    end
  end

  def creator_item
    {
      field: "Creator",
      value: content_block_document.latest_edition.creator.name,
    }
  end

  def edit_action
    {
      href: helpers.content_object_store.edit_content_object_store_content_block_edition_path(content_block_document.latest_edition),
      link_text: "Change",
    }
  end
end
