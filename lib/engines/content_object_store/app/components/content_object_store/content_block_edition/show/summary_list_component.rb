class ContentObjectStore::ContentBlockEdition::Show::SummaryListComponent < ViewComponent::Base
  def initialize(content_block_edition:)
    @content_block_edition = content_block_edition
  end

private

  attr_reader :content_block_edition

  def items
    [title_item].concat(details_items).concat([creator_item])
  end

  def title_item
    {
      field: "Title",
      value: content_block_edition.title,
      edit: edit_action,
    }
  end

  def details_items
    content_block_edition.details.map do |key, value|
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
      value: content_block_edition.creator.name,
    }
  end

  def edit_action
    {
      href: helpers.content_object_store.edit_content_object_store_content_block_edition_path(content_block_edition),
      link_text: "Change",
    }
  end
end
