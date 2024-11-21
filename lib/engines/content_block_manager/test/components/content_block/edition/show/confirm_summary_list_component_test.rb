require "test_helper"

class ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponentTest < ViewComponent::TestCase
  test "it renders instructions to publishers" do
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

  test "renders a summary list component with the edition details to confirm" do
    organisation = create(:organisation, name: "Department for Example")

    content_block_edition = create(
      :content_block_edition,
      :email_address,
      details: { "interesting_fact" => "value of fact" },
      organisation:,
    )

    render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                    content_block_edition:,
                  ))

    assert_selector ".govuk-summary-list__key", text: "Email address details"
    assert_selector ".govuk-summary-list__actions", text: "Edit"
    assert_selector ".govuk-summary-list__key", text: "New interesting fact"
    assert_selector ".govuk-summary-list__value", text: "value of fact"
    assert_selector ".govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__value", text: "Department for Example"
    assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__value", text: "None"
    assert_selector ".govuk-summary-list__key", text: "Confirm"
    assert_selector ".govuk-summary-list__value", text: "I confirm that I am happy for the content block to be changed on these pages."
    assert_selector ".govuk-summary-list__key", text: "Publish date"
    assert_selector ".govuk-summary-list__value", text: I18n.l(content_block_edition.created_at.to_date, format: :long_ordinal)
  end
end
