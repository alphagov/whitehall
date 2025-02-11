require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

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

  let(:content_block_edition) { build(:content_block_edition, :email_address, details:) }

  it "renders a summary list" do
    component = ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryCardComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_name: "my-embedded-object",
    )

    render_inline component

    assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

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
