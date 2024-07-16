require "test_helper"

class ContentObjectStore::ContentBlockEdition::Show::SummaryListComponentTest < ViewComponent::TestCase
  test "renders a content block correctly" do
    content_block_edition = build(
      :content_block_edition,
      :email_address,
      details: { foo: "bar", something: "else" },
      creator: build(:user),
    )
    render_inline(ContentObjectStore::ContentBlockEdition::Show::SummaryListComponent.new(content_block_edition:))

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
