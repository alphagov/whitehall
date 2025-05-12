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

  let(:foo_field) { stub("field", name: "foo", component_name: "string", enum_values: nil) }
  let(:bar_field) { stub("field", name: "bar", component_name: "string", enum_values: nil) }
  let(:baz_field) { stub("field", name: "baz", component_name: "enum", enum_values: %w[some enum]) }

  before do
    schema.stubs(:fields).returns([foo_field, bar_field, baz_field])
  end

  it "renders fields for each property" do
    foo_stub = stub("string_component")
    bar_stub = stub("string_component")
    baz_stub = stub("enum_component")

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

    component = ContentBlockManager::ContentBlockEdition::Details::FormComponent.new(
      content_block_edition:,
      schema:,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)
    component.expects(:render).with(baz_stub)

    render_inline(component)
  end
end
