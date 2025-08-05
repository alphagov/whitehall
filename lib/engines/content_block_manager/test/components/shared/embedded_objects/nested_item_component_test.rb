require "test_helper"

class ContentBlockManager::Shared::EmbeddedObjects::NestedItemComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:nested_items) do
    { "nested_item_field" => "field *value*" }
  end

  let(:component) do
    ContentBlockManager::Shared::EmbeddedObjects::SummaryCard::NestedItemComponent.new(
      nested_items: nested_items,
      object_key: "nested_object",
      title: "Nested object",
      subschema: schema,
    )
  end

  context "when a field is govspeak enabled" do
    let(:schema) do
      stub(
        "sub-schema",
        govspeak_enabled?: true,
      )
    end

    it "renders the value as HTML" do
      render_inline component
      rendered_value = page.find("dt.govuk-summary-list__value").native.children.to_html.strip

      assert_equal(
        "<p>field <em>value</em></p>",
        rendered_value,
      )
    end
  end

  context "when a field is NOT govspeak enabled" do
    let(:schema) do
      stub(
        "sub-schema",
        govspeak_enabled?: false,
      )
    end

    it "renders the value unconverted" do
      render_inline component
      rendered_value = page.find("dt.govuk-summary-list__value").native.children.to_html.strip

      assert_equal(
        "field *value*",
        rendered_value,
      )
    end
  end
end
