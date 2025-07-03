require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:items) do
    {
      "foo" => "bar",
      "fizz" => "buzz",
    }
  end

  let(:object_type) { "telephone" }

  let(:body) do
    {
      "type" => "object",
      "patternProperties" => {
        "*" => {
          "type" => "object",
          "properties" => properties,
        },
      },
    }
  end

  let(:properties) do
    {
      "foo" => {
        "type" => "string",
      },
      "fizz" => {
        "type" => "string",
      },
    }
  end

  let(:schema_id) { "bar" }

  let(:parent_schema_id) { "parent_schema_id" }

  let(:schema) do
    ContentBlockManager::ContentBlock::Schema::EmbeddedSchema.new(schema_id, body, parent_schema_id)
  end

  let(:schema_config) do
    {}
  end

  let(:component) do
    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponent.new(
      items:,
      object_type:,
      schema:,
    )
  end

  before do
    schema.stubs(:config).returns(schema_config)
  end

  context "when NO field order is defined" do
    it "renders a summary list with the expected attributes with no field ordering" do
      component.expects(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Foo",
              value: "bar",
            },
            {
              field: "Fizz",
              value: "buzz",
            },
          ],
        }
      ).returns("STUB_RESPONSE")

      render_inline component

      assert_text "STUB_RESPONSE"
    end
  end

  context "when a field order IS defined" do
    let(:schema_config) do
      {
        "field_order" => %w[fizz foo],
      }
    end

    it "renders a summary list with the defined field ordering (case insensitive)" do
      component.expects(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Fizz",
              value: "buzz",
            },
            {
              field: "Foo",
              value: "bar",
            },
          ],
        }
      ).returns("STUB_RESPONSE")

      render_inline component

      assert_text "STUB_RESPONSE"
    end
  end

  describe "when there is a translated field label" do
    it "uses translated label" do
      I18n.expects(:t).with("content_block_edition.details.labels.telephone.foo", default: "Foo").returns("Foo translated")
      I18n.expects(:t).with("content_block_edition.details.labels.telephone.fizz", default: "Fizz").returns("Fizz translated")

      I18n.expects(:t).with("content_block_edition.details.values.bar", default: "bar").returns("bar")
      I18n.expects(:t).with("content_block_edition.details.values.buzz", default: "buzz").returns("buzz")

      component.expects(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Foo translated",
              value: "bar",
            },
            {
              field: "Fizz translated",
              value: "buzz",
            },
          ],
        }
      ).returns("STUB_RESPONSE")

      render_inline component

      assert_text "STUB_RESPONSE"
    end
  end

  describe "when there is a translated field value" do
    it "uses translated label" do
      I18n.expects(:t).with("content_block_edition.details.labels.telephone.foo", default: "Foo").returns("Foo")
      I18n.expects(:t).with("content_block_edition.details.labels.telephone.fizz", default: "Fizz").returns("Fizz")

      I18n.expects(:t).with("content_block_edition.details.values.bar", default: "bar").returns("Bar translated")
      I18n.expects(:t).with("content_block_edition.details.values.buzz", default: "buzz").returns("Buzz translated")

      component.expects(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Foo",
              value: "Bar translated",
            },
            {
              field: "Fizz",
              value: "Buzz translated",
            },
          ],
        }
      ).returns("STUB_RESPONSE")

      render_inline component

      assert_text "STUB_RESPONSE"
    end
  end
end
