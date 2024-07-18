require "test_helper"

class ContentObjectStore::ContentBlockEdition::Index::SummaryCardComponentTest < ViewComponent::TestCase
  include ContentObjectStore::Engine.routes.url_helpers

  test "it renders a content block as a summary card" do
    content_block_document = build(:content_block_document, :email_address)
    content_block_edition = build(
      :content_block_edition,
      :email_address,
      id: 123,
      details: { foo: "bar", something: "else" },
      content_block_document:, creator: build(:user)
    )

    render_inline(ContentObjectStore::ContentBlockEdition::Index::SummaryCardComponent.new(content_block_edition:))

    assert_selector ".govuk-summary-card__title", text: content_block_edition.title
    assert_selector ".govuk-summary-card__action", count: 1
    assert_selector ".govuk-summary-card__action .govuk-link[href='#{content_object_store_content_block_edition_path(content_block_edition)}']"

    assert_selector ".govuk-summary-list__row", count: 4
    assert_selector ".govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.title
    assert_selector ".govuk-summary-list__key", text: "Foo"
    assert_selector ".govuk-summary-list__value", text: "bar"
    assert_selector ".govuk-summary-list__key", text: "Something"
    assert_selector ".govuk-summary-list__value", text: "else"
    assert_selector ".govuk-summary-list__key", text: "Creator"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.creator.name
  end
end
