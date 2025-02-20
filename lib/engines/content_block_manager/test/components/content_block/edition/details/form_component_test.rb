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

  before do
    schema.stubs(:config_for_field).with(anything).returns({})
  end

  it "renders fields for each property" do
    foo_stub = stub("string_component")
    bar_stub = stub("string_component")
    baz_stub = stub("string_component")

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: "foo",
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: "bar",
    ).returns(bar_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.expects(:new).with(
      content_block_edition:,
      field: "baz",
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

  describe "when a field has a prefix config" do
    let(:body) do
      {
        "type" => "object",
        "required" => %w[foo bar],
        "additionalProperties" => false,
        "properties" => {
          "foo" => {
            "type" => "string",
          },
        },
      }
    end

    before do
      schema.expects(:config_for_field).with("foo").returns({ "field_args" => { "prefix" => "$" } })
    end

    it "sends a prefix to the component" do
      foo_stub = stub("string_component")

      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
        content_block_edition:,
        field: "foo",
        prefix: "$",
      ).returns(foo_stub)

      component = ContentBlockManager::ContentBlockEdition::Details::FormComponent.new(
        content_block_edition:,
        schema:,
      )

      component.expects(:render).with(foo_stub)

      render_inline(component)
    end
  end
end
