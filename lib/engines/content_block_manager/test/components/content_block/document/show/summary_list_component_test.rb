require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::SummaryListComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

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
      updated_at: 1.day.ago,
    )
  end
  let(:content_block_document) { content_block_edition.document }

  it "renders a published content block correctly" do
    render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryListComponent.new(content_block_document:))

    assert_selector ".govuk-summary-list__row", count: 8
    assert_selector ".govuk-summary-list__actions", count: 1

    assert_selector ".govuk-summary-list__key", text: "Email address details"
    assert_selector ".govuk-summary-list__actions", text: "Edit"

    assert_selector ".govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__value", text: content_block_document.title

    assert_selector ".govuk-summary-list__key", text: "Foo"
    assert_selector ".govuk-summary-list__value", text: "bar"

    assert_selector ".govuk-summary-list__key", text: "Something"
    assert_selector ".govuk-summary-list__value", text: "else"

    assert_selector ".govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__value", text: "Department for Example"

    assert_selector ".govuk-summary-list__key", text: "Status"
    assert_selector ".govuk-summary-list__value", text: "Published 1 day ago by #{content_block_edition.creator.name}"

    assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__value", text: "None"

    assert_selector ".govuk-summary-list__row[data-module='copy-embed-code']", text: "Embed code"
    assert_selector ".govuk-summary-list__row[data-embed-code='#{content_block_document.embed_code}']", text: "Embed code"
    assert_selector ".govuk-summary-list__key", text: "Embed code"
    assert_selector ".govuk-summary-list__value", text: content_block_document.embed_code
  end

  it "renders a scheduled content block correctly" do
    content_block_document.latest_edition.state = "scheduled"

    render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryListComponent.new(content_block_document:))

    assert_selector ".govuk-summary-list__row", count: 8

    assert_selector ".govuk-summary-list__key", text: "Status"
    assert_selector ".govuk-summary-list__value", text: "Scheduled for publication at #{I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)}"
    assert_selector ".govuk-summary-list__actions", text: "Edit schedule"
    assert_selector ".govuk-summary-list__actions a[href='#{content_block_manager_content_block_document_schedule_edit_path(content_block_document)}']"
  end

  describe "when there are instructions to publishers" do
    it "renders them" do
      content_block_document.latest_edition.instructions_to_publishers = "instructions"

      render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryListComponent.new(content_block_document:))

      assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
      assert_selector ".govuk-summary-list__value", text: "instructions"
    end
  end

  describe "when the content block contains nested content" do
    it "shows a list of keys and values for each embedded item" do
      content_block_document.latest_edition.details = { "facts" => [
        { "interesting_fact" => "value 1 of fact", "another_interesting_fact" => "another value 1 of fact" },
        { "interesting_fact" => "value 2 of fact", "another_interesting_fact" => "another value 2 of fact" },
      ] }

      render_inline(ContentBlockManager::ContentBlock::Document::Show::SummaryListComponent.new(content_block_document:))

      page.find ".govuk-summary-list__row", text: "Fact 1" do
        assert_selector "li", text: "Interesting fact: value 1 of fact"
        assert_selector "li", text: "Another interesting fact: another value 1 of fact"
      end

      page.find ".govuk-summary-list__row", text: "Fact 2" do
        assert_selector "li", text: "Interesting fact: value 2 of fact"
        assert_selector "li", text: "Another interesting fact: another value 2 of fact"
      end
    end
  end
end
