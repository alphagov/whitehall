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
          "type" => "array",
          "items" => {
            "type" => "object",
            "required" => %w[item1 item2],
            "additionalProperties" => false,
            "properties" => {
              "item1" => {
                "type" => "string",
              },
              "item2" => {
                "type" => "string",
              },
            },
          },
        },
      },
    }
  end

  let(:content_block_edition) { build(:content_block_edition) }
  let(:schema) { build(:content_block_schema, body:) }

  it "renders fields for each property" do
    foo_stub = stub("string_component")
    bar_stub = stub("array_component")

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: "foo",
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent.expects(:new).with(
      content_block_edition:,
      field: "bar",
      properties: %w[item1 item2],
    ).returns(bar_stub)

    component = ContentBlockManager::ContentBlockEdition::Details::FormComponent.new(
      content_block_edition:,
      schema:,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)

    render_inline(component)
  end
end
