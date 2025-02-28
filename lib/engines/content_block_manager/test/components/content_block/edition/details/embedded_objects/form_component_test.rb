require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponentTest < ViewComponent::TestCase
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
      },
    }
  end

  let(:content_block_edition) { build(:content_block_edition) }
  let(:schema) { build(:content_block_schema, body:) }

  let(:foo_stub) { stub("string_component") }
  let(:bar_stub) { stub("string_component") }
  let(:object_title) { "some_object" }

  it "renders fields for each property" do
    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      label: "Foo",
      field: [object_title, "foo"],
      id_suffix: "#{object_title}_foo",
      value: nil,
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      label: "Bar",
      field: [object_title, "bar"],
      id_suffix: "#{object_title}_bar",
      value: nil,
    ).returns(bar_stub)

    component = ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent.new(
      content_block_edition:,
      schema:,
      object_title:,
      params: nil,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)

    render_inline(component)
  end

  it "sends the value of a field if present in the params argument" do
    params = { "foo" => "something" }

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      label: "Foo",
      field: [object_title, "foo"],
      id_suffix: "#{object_title}_foo",
      value: "something",
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      label: "Bar",
      field: [object_title, "bar"],
      id_suffix: "#{object_title}_bar",
      value: nil,
    ).returns(bar_stub)

    component = ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent.new(
      content_block_edition:,
      schema:,
      object_title:,
      params:,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)

    render_inline(component)
  end
end
