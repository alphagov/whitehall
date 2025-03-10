require "test_helper"

class ContentBlockManager::ContentBlock::Document::Index::SummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  include ContentBlockManager::Engine.routes.url_helpers

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::SanitizeHelper
  include ContentBlockManager::ContentBlock::EditionHelper

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

  before do
    content_block_document.expects(:latest_edition).at_least_once.returns(content_block_edition)
  end

  it "renders a published content block as a summary card" do
    render_inline(ContentBlockManager::ContentBlock::Document::Index::SummaryCardComponent.new(content_block_document:))

    assert_selector ".govuk-summary-card__title", text: content_block_edition.title
    assert_selector ".govuk-summary-card__action", count: 1
    assert_selector ".govuk-summary-card__action .govuk-link[href='#{content_block_manager_content_block_document_path(content_block_document)}']"

    assert_selector ".govuk-link", text: "View"

    assert_selector ".govuk-summary-list__row", count: 5

    assert_selector ".govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.title

    assert_selector ".govuk-summary-list__key", text: "Foo"
    assert_selector ".govuk-summary-list__value", text: "bar"

    assert_selector ".govuk-summary-list__key", text: "Something"
    assert_selector ".govuk-summary-list__value", text: "else"

    assert_selector ".govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__value", text: content_block_edition.lead_organisation.name

    assert_no_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_no_selector ".govuk-summary-list__value", text: "None"

    assert_selector ".govuk-summary-list__key", text: "Status"
    assert_selector ".govuk-summary-list__value", text: "Published on #{strip_tags published_date(content_block_edition)} by #{content_block_edition.creator.name}"
  end

  describe "when there are instructions to publishers" do
    it "renders them" do
      content_block_document.latest_edition.instructions_to_publishers = "instructions"

      render_inline(ContentBlockManager::ContentBlock::Document::Index::SummaryCardComponent.new(content_block_document:))

      assert_selector ".govuk-summary-list__row", count: 6

      assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
      assert_selector ".govuk-summary-list__value", text: "instructions"
    end
  end

  describe "when the edition is scheduled" do
    it "returns the scheduled value" do
      content_block_edition.state = "scheduled"
      content_block_edition.scheduled_publication = Time.zone.now

      render_inline(ContentBlockManager::ContentBlock::Document::Index::SummaryCardComponent.new(content_block_document:))

      assert_selector ".govuk-summary-list__row", count: 5

      assert_selector ".govuk-summary-list__key", text: "Status"
      assert_selector ".govuk-summary-list__value", text: "Scheduled for publication at #{strip_tags scheduled_date(content_block_edition)}"
    end
  end
end
