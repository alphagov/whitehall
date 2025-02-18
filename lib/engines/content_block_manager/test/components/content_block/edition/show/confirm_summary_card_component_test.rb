require "test_helper"

class ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  it "it renders instructions to publishers" do
    content_block_edition = create(
      :content_block_edition,
      :email_address,
      instructions_to_publishers: "some instructions",
    )

    render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryCardComponent.new(
                    content_block_edition:,
                  ))

    assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__value", text: "some instructions"
  end

  it "renders a summary card component with the edition details to confirm" do
    organisation = create(:organisation, name: "Department for Example")

    content_block_document = create(:content_block_document, :email_address)
    content_block_document.stubs(:is_new_block?).returns(false)

    content_block_edition = create(
      :content_block_edition,
      :email_address,
      title: "Some edition title",
      details: { "interesting_fact" => "value of fact", "something" => { "else" => "value" } },
      organisation:,
      document: content_block_document,
    )

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
