require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::FormComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:body) do
    {
      "type" => "object",
      "required" => %w[foo bar],
      "additionalProperties" => false,
      "properties" => {
        "foo" => {
          "type" => "string",
        },
        "bar" => {
          "type" => "string",
        },
        "baz" => {
          "type" => "string",
          "enum" => %w[some enum],
        },
      },
    }
  end

  let(:content_block_edition) { build(:content_block_edition) }
  let(:schema) { build(:content_block_schema, body:) }

  let(:foo_field) { stub("field", name: "foo", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:bar_field) { stub("field", name: "bar", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:baz_field) { stub("field", name: "baz", component_name: "enum", enum_values: %w[some enum], default_value: nil, data_attributes: nil) }

  let(:foo_stub) { stub("string_component") }
  let(:bar_stub) { stub("string_component") }
  let(:baz_stub) { stub("enum_component") }

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::FormComponent.new(
      content_block_edition:,
      schema:,
    )
  end

  before do
    schema.stubs(:fields).returns([foo_field, bar_field, baz_field])
    component.expects(:render).with(foo_stub).returns("foo_stub")
    component.expects(:render).with(bar_stub).returns("bar_stub")
    component.expects(:render).with(baz_stub).returns("baz_stub")
  end

  it "renders fields for each property" do
    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: foo_field,
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: bar_field,
    ).returns(bar_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.expects(:new).with(
      content_block_edition:,
      field: baz_field,
      enum: %w[some enum],
    ).returns(baz_stub)

    assert render_inline(component)
  end

  it "sends values to the field components when the block has them" do
    content_block_edition.details = {
      "foo" => "foo value",
      "bar" => "bar value",
      "baz" => "baz value",
    }

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: foo_field,
      value: "foo value",
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: bar_field,
      value: "bar value",
    ).returns(bar_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.expects(:new).with(
      content_block_edition:,
      field: baz_field,
      value: "baz value",
      enum: %w[some enum],
    ).returns(baz_stub)

    assert render_inline(component)
  end

  describe "when data_attributes are provided" do
    let(:foo_field) { stub("field", name: "foo", component_name: "string", enum_values: nil, default_value: nil, data_attributes: { "field" => "foo" }) }
    let(:bar_field) { stub("field", name: "bar", component_name: "string", enum_values: nil, default_value: nil, data_attributes: { "field" => "bar" }) }
    let(:baz_field) { stub("field", name: "baz", component_name: "enum", enum_values: %w[some enum], default_value: nil, data_attributes: { "field" => "baz" }) }

    it "renders inside a div with data attributes" do
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
        content_block_edition:,
        field: foo_field,
      ).returns(foo_stub)

      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
        content_block_edition:,
        field: bar_field,
      ).returns(bar_stub)

      ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.expects(:new).with(
        content_block_edition:,
        field: baz_field,
        enum: %w[some enum],
      ).returns(baz_stub)

      render_inline(component)

      assert_selector "div[data-field='foo']" do |component|
        component.assert_text "foo_stub"
      end

      assert_selector "div[data-field='bar']" do |component|
        component.assert_text "bar_stub"
      end

      assert_selector "div[data-field='baz']" do |component|
        component.assert_text "baz_stub"
      end
    end
  end
end
