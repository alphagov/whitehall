class ContentObjectStore::ContentBlock::Document::Show::SummaryListComponent < ViewComponent::Base
  def initialize(content_block_document:)
    @content_block_document = content_block_document
  end

private

  attr_reader :content_block_document

  def items
    [
      title_item,
      *details_items,
      organisation_item,
      creator_item,
      embed_code_item,
    ]
  end

  def embed_code_item
    {
      field: "Embed code",
      value: content_block_document.embed_code,
    }
  end

  def title_item
    {
      field: "Title",
      value: content_block_document.title,
      edit: edit_action,
    }
  end

  def organisation_item
    {
      field: "Lead organisation",
      value: content_block_document.latest_edition.lead_organisation,
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
