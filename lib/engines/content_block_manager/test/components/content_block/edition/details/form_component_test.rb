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
end
