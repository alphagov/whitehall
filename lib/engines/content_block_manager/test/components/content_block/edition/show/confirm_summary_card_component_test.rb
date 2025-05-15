require "test_helper"

class ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:organisation) { build(:organisation, name: "Department for Example") }
  let(:content_block_document) { create(:content_block_document, :email_address) }
  let(:content_block_edition) do
    build_stubbed(:content_block_edition, :email_address,
                  title: "Some edition title",
                  details: { "interesting_fact" => "value of fact", "something" => { "else" => "value" } },
                  organisation:,
                  document: content_block_document)
  end
  let(:fields) do
    [
      stub("field", name: "interesting_fact"),
    ]
  end
  let(:schema) { stub(:schema, fields:) }

  before do
    content_block_edition.document.expects(:schema).returns(schema)
  end

  it "it renders instructions to publishers" do
    content_block_edition.instructions_to_publishers = "some instructions"

    render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryCardComponent.new(
                    content_block_edition:,
                  ))

    assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__value p", text: "some instructions"
  end

  it "renders a summary card component with the edition details to confirm" do
    content_block_document.stubs(:is_new_block?).returns(false)

    render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryCardComponent.new(
                    content_block_edition:,
                  ))

    assert_selector ".govuk-summary-list__row", count: 4

    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "Some edition title"

    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Interesting fact"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "value of fact"

    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: "Department for Example"

    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: "None"
  end
end
