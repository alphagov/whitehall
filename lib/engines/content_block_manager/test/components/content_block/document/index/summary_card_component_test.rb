require "test_helper"

class ContentBlockManager::ContentBlock::Document::Index::SummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  include ContentBlockManager::Engine.routes.url_helpers

  let(:content_block_edition) do
    create(
      :content_block_edition,
      :email_address,
      id: 123,
      details: { foo: "bar", something: "else" },
      creator: build(:user),
      organisation: build(:organisation),
      scheduled_publication: Time.zone.now,
      state: "published",
      updated_at: 1.day.ago,
    )
  end

  let(:content_block_document) { content_block_edition.document }

  it "renders a published content block as a summary card" do
    render_inline(ContentBlockManager::ContentBlock::Document::Index::SummaryCardComponent.new(content_block_document:))

    assert_selector ".govuk-summary-card__title", text: content_block_edition.title
    assert_selector ".govuk-summary-card__action", count: 1
    assert_selector ".govuk-summary-card__action .govuk-link[href='#{content_block_manager_content_block_document_path(content_block_document)}']"

    assert_selector ".govuk-summary-list__row", count: 6

    assert_selector ".govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.title

    assert_selector ".govuk-summary-list__key", text: "Foo"
    assert_selector ".govuk-summary-list__value", text: "bar"

    assert_selector ".govuk-summary-list__key", text: "Something"
    assert_selector ".govuk-summary-list__value", text: "else"

    assert_selector ".govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.lead_organisation.name

    assert_selector ".govuk-summary-list__key", text: "Last updated"
    assert_selector ".govuk-summary-list__value", text: "1 day ago by #{content_block_edition.creator.name}"

    assert_selector ".govuk-summary-list__row[data-module='copy-embed-code']", text: "Embed code"
    assert_selector ".govuk-summary-list__row[data-embed-code='#{content_block_document.embed_code}']", text: "Embed code"
    assert_selector ".govuk-summary-list__key", text: "Embed code"
    assert_selector ".govuk-summary-list__value", text: content_block_document.embed_code
  end
end
