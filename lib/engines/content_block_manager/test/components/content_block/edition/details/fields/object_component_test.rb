require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:nested_fields) do
    [
      stub("field", name: "label", component_class: ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent, parent_name: "foo", enum_values: nil, default_value: nil),
      stub("field", name: "type", component_class: ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent, parent_name: "foo", enum_values: %w[enum_1 enum_2 enum_3], default_value: nil),
      stub("field", name: "email_address", component_class: ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent, parent_name: "foo", enum_values: nil, default_value: nil),
    ]
  end
  let(:schema) { stub("schema", id: "root") }
  let(:field) { stub("field", name: "nested", nested_fields:, schema:) }

  let(:label_stub) { stub("string_component") }
  let(:type_stub) { stub("enum_component") }
  let(:email_address_stub) { stub("string_component") }

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent.new(
      content_block_edition:,
      field:,
    )
  end

  it "renders fields for each property" do
    render_inline(component)

    assert_selector(".govuk-fieldset") do |fieldset|
      fieldset.assert_selector ".govuk-fieldset__legend--m h3", text: field.name.humanize
      fieldset.assert_selector ".govuk-form-group", count: 3

      fieldset.assert_selector ".govuk-form-group", text: /Label/ do |form_group|
        form_group.assert_selector "input[name=\"content_block/edition[details][root][foo][label]\"]"
      end

      fieldset.assert_selector ".govuk-form-group", text: /Type/ do |form_group|
        form_group.assert_selector "select[name=\"content_block/edition[details][root][foo][type]\"]"
      end

      fieldset.assert_selector ".govuk-form-group", text: /Email address/ do |form_group|
        form_group.assert_selector "input[name=\"content_block/edition[details][root][foo][email_address]\"]"
      end
    end
  end
end
