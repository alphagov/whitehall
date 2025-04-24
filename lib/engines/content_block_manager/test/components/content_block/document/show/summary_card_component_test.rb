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
  let(:schema_with_embeddable_fields) { stub(:schema, embeddable_fields: %w[foo]) }
  let(:schema_without_embeddable_fields) { stub(:schema, embeddable_fields: []) }
  let(:content_block_document) { content_block_edition.document }

  before do
    content_block_document.stubs(:schema).returns(schema_without_embeddable_fields)
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
      assert_selector ".govuk-summary-list__value p", text: "instructions"
    end
  end

  describe "when there are embeddable fields in scheme" do
    before do
      content_block_document.stubs(:schema).returns(schema_with_embeddable_fields)
    end

    it "assembles the embed code functionality" do
      render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryCardComponent.new(content_block_document:))

      assert_selector ".govuk-summary-list__row", count: 7

      assert_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('foo')}']", text: "Foo"
      assert_selector ".govuk-summary-list__row[data-module='copy-embed-code']", text: "Foo"

      assert_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("foo")
    end
  end
end
