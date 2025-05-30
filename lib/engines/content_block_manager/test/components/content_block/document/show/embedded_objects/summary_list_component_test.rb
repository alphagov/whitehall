require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabGroupComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:details) do
    {
      "embedded-objects" => {
        "my-embedded-object" => {
          "name" => "My Embedded Object",
          "field-2" => "Value 2",
          "field-1" => "Value 1",
        },
      },
    }
  end

  let(:content_block_edition) { build_stubbed(:content_block_edition, :contact, details:) }

  it "renders a summary list" do
    component = ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryListComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
    )

    render_inline component

    assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
      assert_selector ".govuk-summary-list__key", text: "Name"
      assert_selector ".govuk-summary-list__value", text: "My Embedded Object"
    end

    assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_field_1']", text: /Field 1/ do
      assert_selector ".govuk-summary-list__key", text: "Field 1"
      assert_selector ".govuk-summary-list__value", text: "Value 1"
    end

    assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_field_2']", text: /Field 2/ do
      assert_selector ".govuk-summary-list__key", text: "Field 2"
      assert_selector ".govuk-summary-list__value", text: "Value 2"
    end
  end

  it "renders embed code rows for all attributes" do
    component = ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryListComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
    )

    render_inline component

    assert_selector ".govuk-summary-list__value", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/name")
    assert_selector ".govuk-summary-list__value", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/field-1")
    assert_selector ".govuk-summary-list__value", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/field-2")
  end
end
