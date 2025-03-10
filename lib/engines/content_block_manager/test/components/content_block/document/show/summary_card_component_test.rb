require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::SummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::SanitizeHelper
  include ContentBlockManager::ContentBlock::EditionHelper

  include ContentBlockManager::Engine.routes.url_helpers

  let(:organisation) { create(:organisation, name: "Department for Example") }
  let!(:content_block_edition) do
    create(
      :content_block_edition,
      :email_address,
      details: { foo: "bar", something: "else", "embedded" => { "something" => { "is" => "here" } } },
      creator: build(:user),
      organisation:,
      scheduled_publication: Time.zone.now,
      state: "published",
      updated_at: 1.day.ago,
    )
  end
  let(:content_block_document) { content_block_edition.document }

  it "renders a published content block correctly" do
    render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryCardComponent.new(content_block_document:))

    assert_selector ".govuk-summary-list__row", count: 6

    assert_selector ".govuk-summary-card__title", text: "Email address details"

    assert_selector ".govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__value", text: content_block_document.title

    assert_selector ".govuk-summary-list__key", text: "Foo"
    assert_selector ".govuk-summary-list__value", text: "bar"

    assert_selector ".govuk-summary-list__key", text: "Something"
    assert_selector ".govuk-summary-list__value", text: "else"

    assert_selector ".govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__value", text: "Department for Example"

    assert_selector ".govuk-summary-list__key", text: "Status"
    assert_selector ".govuk-summary-list__value", text: "Published on #{strip_tags published_date(content_block_edition)} by #{content_block_edition.creator.name}"

    assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__value", text: "None"
  end

  it "renders a scheduled content block correctly" do
    content_block_document.latest_edition.state = "scheduled"

    render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryCardComponent.new(content_block_document:))

    assert_selector ".govuk-summary-list__row", count: 6

    assert_selector ".govuk-summary-list__key", text: "Status"
    assert_selector ".govuk-summary-list__value", text: "Scheduled for publication at #{strip_tags scheduled_date(content_block_edition)}"
    assert_selector ".govuk-summary-list__actions", text: "Edit schedule"
    assert_selector ".govuk-summary-list__actions a[href='#{content_block_manager_content_block_document_schedule_edit_path(content_block_document)}']"
  end

  describe "when there are instructions to publishers" do
    it "renders them" do
      content_block_document.latest_edition.instructions_to_publishers = "instructions"

      render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryCardComponent.new(content_block_document:))

      assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
      assert_selector ".govuk-summary-list__value", text: "instructions"
    end
  end
end
