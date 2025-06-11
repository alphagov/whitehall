require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition) }
  let(:schema) { build(:content_block_schema) }

  let(:foo_field) { stub("field", name: "foo", component_name: "string", enum_values: nil, default_value: nil) }
  let(:bar_field) { stub("field", name: "bar", component_name: "string", enum_values: nil, default_value: nil) }
  let(:enum_field) { stub("field", name: "enum", component_name: "enum", enum_values: ["some value", "another value"], default_value: "some value") }

  let(:foo_stub) { stub("string_component") }
  let(:bar_stub) { stub("string_component") }
  let(:enum_stub) { stub("enum_component") }

  let(:object_title) { "some_object" }

  before do
    schema.stubs(:fields).returns([foo_field, bar_field, enum_field])
  end

  it "renders fields for each property" do
    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: foo_field,
      parent_objects: [object_title],
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: bar_field,
      parent_objects: [object_title],
    ).returns(bar_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.expects(:new).with(
      content_block_edition:,
      field: enum_field,
      parent_objects: [object_title],
      enum: ["some value", "another value"],
      default: "some value",
    ).returns(enum_stub)

    component = ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent.new(
      content_block_edition:,
      schema:,
      object_title:,
      params: nil,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)
    component.expects(:render).with(enum_stub)

    render_inline(component)
  end

  it "sends the value of a field if present in the params argument" do
    params = { "foo" => "something" }

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: foo_field,
      parent_objects: [object_title],
      value: "something",
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: bar_field,
      parent_objects: [object_title],
    ).returns(bar_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.expects(:new).with(
      content_block_edition:,
      field: enum_field,
      parent_objects: [object_title],
      enum: ["some value", "another value"],
      default: "some value",
    ).returns(enum_stub)

    component = ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent.new(
      content_block_edition:,
      schema:,
      object_title:,
      params:,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)
    component.expects(:render).with(enum_stub)

    render_inline(component)
  end
end
