class ContentObjectStore::ContentBlockEdition::Show::SummaryListComponent < ViewComponent::Base
  def initialize(content_block_edition:)
    @content_block_edition = content_block_edition
  end

private

  attr_reader :content_block_edition

  def items
    [title_item].concat(details_items)
  end

  def title_item
    {
      field: "Title",
      value: content_block_edition.title,
    }
  end

  def details_items
    @content_block_edition.details.map do |key, value|
      { field: key.humanize, value: }
    end
  end
end
