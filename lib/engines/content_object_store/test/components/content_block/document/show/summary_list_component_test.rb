require "test_helper"

class ContentObjectStore::ContentBlock::Document::Show::SummaryListComponentTest < ViewComponent::TestCase
  test "renders a content block correctly" do
    organisation = create(:organisation, name: "Department for Example")

    content_block_edition = create(
      :content_block_edition,
      :email_address,
      details: { foo: "bar", something: "else" },
      creator: build(:user),
      organisation:,
    )
    content_block_document = content_block_edition.document

    render_inline(ContentObjectStore::ContentBlock::Document::Show::SummaryListComponent.new(content_block_document:))

    assert_selector ".govuk-summary-list__row", count: 8
    assert_selector ".govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__value", text: content_block_document.title
    assert_selector ".govuk-summary-list__actions", text: "Change"

    assert_selector ".govuk-summary-list__key", text: "Foo"
    assert_selector ".govuk-summary-list__value", text: "bar"
    assert_selector ".govuk-summary-list__actions", text: "Change"

    assert_selector ".govuk-summary-list__key", text: "Something"
    assert_selector ".govuk-summary-list__value", text: "else"
    assert_selector ".govuk-summary-list__actions", text: "Change"

    assert_selector ".govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__value", text: "Department for Example"

    assert_selector ".govuk-summary-list__key", text: "Creator"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.creator.name

    assert_selector ".govuk-summary-list__key", text: "Embed code"
    assert_selector ".govuk-summary-list__value", text: content_block_document.embed_code

    assert_selector ".govuk-summary-list__key", text: "State"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.state

    assert_selector ".govuk-summary-list__key", text: "Scheduled for publication at"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.scheduled_publication&.strftime("%e %B %Y at %I:%M%P")
  end
end
