require "test_helper"

class ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  it "it renders instructions to publishers" do
    content_block_edition = create(
      :content_block_edition,
      :email_address,
      instructions_to_publishers: "some instructions",
    )

    render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                    content_block_edition:,
                  ))

    assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__value", text: "some instructions"
  end

  it "renders a summary list component with the edition details to confirm" do
    organisation = create(:organisation, name: "Department for Example")

    content_block_document = create(:content_block_document, :email_address, title: "Some title")

    content_block_edition = create(
      :content_block_edition,
      :email_address,
      details: { "interesting_fact" => "value of fact" },
      organisation:,
      document: content_block_document,
    )

    render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                    content_block_edition:,
                  ))

    assert_selector ".govuk-summary-list__key", text: "Email address details"
    assert_selector ".govuk-summary-list__actions", text: "Edit"
    assert_selector ".govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__value", text: "Some title"
    assert_selector ".govuk-summary-list__key", text: "New interesting fact"
    assert_selector ".govuk-summary-list__value", text: "value of fact"
    assert_selector ".govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__value", text: "Department for Example"
    assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__value", text: "None"
  end
end
