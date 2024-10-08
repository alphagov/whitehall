require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::SummaryListComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:organisation) { create(:organisation, name: "Department for Example") }
  let(:content_block_edition) do
    create(
      :content_block_edition,
      :email_address,
      details: { foo: "bar", something: "else" },
      creator: build(:user),
      organisation:,
      scheduled_publication: Time.zone.now,
      state: "published",
    )
  end
  let(:content_block_document) { content_block_edition.document }

  it "renders a published content block correctly" do
    render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryListComponent.new(content_block_document:))

    assert_selector ".govuk-summary-list__row", count: 7
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
    assert_selector ".govuk-summary-list__value", text: content_block_edition.state.titleize
  end

  it "renders a scheduled content block correctly" do
    content_block_document.latest_edition.state = "scheduled"

    render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryListComponent.new(content_block_document:))

    assert_selector ".govuk-summary-list__row", count: 8

    assert_selector ".govuk-summary-list__key", text: "Scheduled for publication at"
    assert_selector ".govuk-summary-list__value", text: I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)
  end
end
