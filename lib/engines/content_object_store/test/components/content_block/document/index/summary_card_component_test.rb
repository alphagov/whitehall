require "test_helper"

class ContentObjectStore::ContentBlock::Document::Index::SummaryCardComponentTest < ViewComponent::TestCase
  include ContentObjectStore::Engine.routes.url_helpers

  test "it renders a content block as a summary card" do
    content_block_edition = create(
      :content_block_edition,
      :email_address,
      id: 123,
      details: { foo: "bar", something: "else" },
      creator: build(:user),
      organisation: build(:organisation),
      scheduled_publication: Time.zone.now,
    )
    content_block_document = content_block_edition.document

    render_inline(ContentObjectStore::ContentBlock::Document::Index::SummaryCardComponent.new(content_block_document:))

    assert_selector ".govuk-summary-card__title", text: content_block_edition.title
    assert_selector ".govuk-summary-card__action", count: 1
    assert_selector ".govuk-summary-card__action .govuk-link[href='#{content_object_store_content_block_document_path(content_block_document)}']"

    assert_selector ".govuk-summary-list__row", count: 8

    assert_selector ".govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.title

    assert_selector ".govuk-summary-list__key", text: "Foo"
    assert_selector ".govuk-summary-list__value", text: "bar"

    assert_selector ".govuk-summary-list__key", text: "Something"
    assert_selector ".govuk-summary-list__value", text: "else"

    assert_selector ".govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.lead_organisation.name

    assert_selector ".govuk-summary-list__key", text: "Creator"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.creator.name

    assert_selector ".govuk-summary-list__key", text: "Embed code"
    assert_selector ".govuk-summary-list__value", text: content_block_document.embed_code

    assert_selector ".govuk-summary-list__key", text: "State"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.state

    assert_selector ".govuk-summary-list__key", text: "Scheduled for publication at"
    assert_selector ".govuk-summary-list__value", text: I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)
  end
end
