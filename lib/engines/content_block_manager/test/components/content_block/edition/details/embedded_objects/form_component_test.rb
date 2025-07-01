require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition) }

  let(:block_type) { "some_object" }
  let(:subschema) { build(:content_block_schema, block_type:) }

  let(:foo_field) { stub("field", name: "foo", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:bar_field) { stub("field", name: "bar", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:enum_field) { stub("field", name: "enum", component_name: "enum", enum_values: ["some value", "another value"], default_value: "some value", data_attributes: nil) }
  let(:textarea_field) { stub("field", name: "enum", component_name: "textarea", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:boolean_field) { stub("field", name: "boolean", component_name: "boolean", enum_values: nil, default_value: nil, data_attributes: nil) }

  let(:foo_stub) { stub("string_component") }
  let(:bar_stub) { stub("string_component") }
  let(:enum_stub) { stub("enum_component") }
  let(:textarea_stub) { stub("textarea_component") }
  let(:boolean_stub) { stub("boolean_component") }

  before do
    subschema.stubs(:fields).returns([foo_field, bar_field, enum_field, textarea_field, boolean_field])
  end

  it "renders fields for each property" do
    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: foo_field,
      subschema:,
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: bar_field,
      subschema:,
    ).returns(bar_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.expects(:new).with(
      content_block_edition:,
      field: enum_field,
      subschema:,
      enum: ["some value", "another value"],
      default: "some value",
    ).returns(enum_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::TextareaComponent.expects(:new).with(
      content_block_edition:,
      field: textarea_field,
      subschema:,
    ).returns(textarea_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponent.expects(:new).with(
      content_block_edition:,
      field: boolean_field,
      subschema:,
    ).returns(boolean_stub)

    component = ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent.new(
      content_block_edition:,
      subschema:,
      params: nil,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)
    component.expects(:render).with(enum_stub)
    component.expects(:render).with(textarea_stub)
    component.expects(:render).with(boolean_stub)

    render_inline(component)
  end

  it "sends the value of a field if present in the params argument" do
    params = { "foo" => "something" }

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: foo_field,
      subschema:,
      value: "something",
    ).returns(foo_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.expects(:new).with(
      content_block_edition:,
      field: bar_field,
      subschema:,
    ).returns(bar_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.expects(:new).with(
      content_block_edition:,
      field: enum_field,
      subschema:,
      enum: ["some value", "another value"],
      default: "some value",
    ).returns(enum_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::TextareaComponent.expects(:new).with(
      content_block_edition:,
      field: textarea_field,
      subschema:,
    ).returns(textarea_stub)

    ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponent.expects(:new).with(
      content_block_edition:,
      field: boolean_field,
      subschema:,
    ).returns(boolean_stub)

    component = ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent.new(
      content_block_edition:,
      subschema:,
      params:,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)
    component.expects(:render).with(enum_stub)
    component.expects(:render).with(textarea_stub)
    component.expects(:render).with(boolean_stub)

    render_inline(component)
  end
end
