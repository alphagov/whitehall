class ContentObjectStore::ContentBlockEdition::Show::ConfirmSummaryListComponent < ViewComponent::Base
  def initialize(content_block_edition:)
    @content_block_edition = content_block_edition
  end

private

  attr_reader :content_block_edition

  def items
    details_items.push(confirm_item).push(date_item)
  end

  def details_items
    content_block_edition.details.map do |key, value|
      {
        field: "New #{key.humanize.downcase}",
        value:,
      }
    end
  end

  def confirm_item
    {
      field: "Confirm",
      value: "I confirm that I am happy for the content block to be changed on these pages.",
    }
  end

  def date_item
    {
      field: "Publish date",
      value: Date.current.strftime("%d %B %Y"),
    }
  end
end
