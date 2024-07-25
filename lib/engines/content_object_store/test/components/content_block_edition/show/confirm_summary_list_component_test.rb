require "test_helper"

class ContentObjectStore::ContentBlockEdition::Show::ConfirmSummaryListComponentTest < ViewComponent::TestCase
  test "renders a summary list component with the edition details to confirm" do
    @user = create(:user)
    @content_block_edition = create(:content_block_edition, :email_address, details: { "interesting_fact" => "value of fact" })

    render_inline(ContentObjectStore::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                    content_block_edition: @content_block_edition,
                  ))

    assert_selector ".govuk-summary-list__key", text: "New interesting fact"
    assert_selector ".govuk-summary-list__value", text: "value of fact"
    assert_selector ".govuk-summary-list__key", text: "Confirm"
    assert_selector ".govuk-summary-list__value", text: "I confirm that I am happy for the content block to be changed on these pages."
    assert_selector ".govuk-summary-list__key", text: "Publish date"
    assert_selector ".govuk-summary-list__value", text: @content_block_edition.created_at.strftime("%d %B %Y")
  end
end
