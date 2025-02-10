require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::ConfirmSummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:details) do
    {
      "embedded-objects" => {
        "my-embedded-object" => {
          "name" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
      },
    }
  end

  let(:content_block_edition) { build_stubbed(:content_block_edition, :email_address, details:) }

  it "renders a summary list" do
    component = ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::ConfirmSummaryCardComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_name: "my-embedded-object",
    )

    render_inline component

    assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

    expected_edit_path = edit_embedded_object_content_block_manager_content_block_edition_path(
      content_block_edition,
      object_type: "embedded-objects",
      object_name: "my-embedded-object",
    )

    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{expected_edit_path}']", text: "Edit"

    assert_selector ".govuk-summary-list__row", text: /Name/ do
      assert_selector ".govuk-summary-list__key", text: "Name"
      assert_selector ".govuk-summary-list__value", text: "My Embedded Object"
    end

    assert_selector ".govuk-summary-list__row", text: /Field 1/ do
      assert_selector ".govuk-summary-list__key", text: "Field 1"
      assert_selector ".govuk-summary-list__value", text: "Value 1"
    end

    assert_selector ".govuk-summary-list__row", text: /Field 2/ do
      assert_selector ".govuk-summary-list__key", text: "Field 2"
      assert_selector ".govuk-summary-list__value", text: "Value 2"
    end
  end
end
