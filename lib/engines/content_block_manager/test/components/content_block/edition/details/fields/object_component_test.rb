require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:nested_fields) do
    [
      stub("field", name: "label", enum_values: nil, default_value: nil),
      stub("field", name: "type", enum_values: %w[enum_1 enum_2 enum_3], default_value: nil),
      stub("field", name: "email_address", enum_values: nil, default_value: nil),
    ]
  end
  let(:schema) { stub("schema", id: "root") }
  let(:field) { stub("field", name: "nested", nested_fields:, schema:, is_required?: true, default_value: nil) }

  let(:label_stub) { stub("string_component") }
  let(:type_stub) { stub("enum_component") }
  let(:email_address_stub) { stub("string_component") }

  let(:form_value) { nil }

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent.new(
      content_block_edition:,
      field:,
      value: form_value,
    )
  end

  it "renders fields for each property" do
    render_inline(component)

    assert_selector(".govuk-fieldset") do |fieldset|
      fieldset.assert_selector ".govuk-fieldset__legend--m h3", text: field.name.humanize
      fieldset.assert_selector ".govuk-form-group", count: 3

      fieldset.assert_selector ".govuk-form-group", text: /Label/ do |form_group|
        form_group.assert_selector "input[name=\"content_block/edition[details][nested][label]\"]"
      end

      fieldset.assert_selector ".govuk-form-group", text: /Type/ do |form_group|
        form_group.assert_selector "input[name=\"content_block/edition[details][nested][type]\"]"
      end

      fieldset.assert_selector ".govuk-form-group", text: /Email address/ do |form_group|
        form_group.assert_selector "input[name=\"content_block/edition[details][nested][email_address]\"]"
      end
    end
  end

  describe "when values are present for the object" do
    let(:form_value) do
      {
        "label" => "something",
      }
    end

    it "renders the field with the value" do
      render_inline(component)

      assert_selector "input[name=\"content_block/edition[details][nested][label]\"][value=\"something\"]"
    end
  end

  describe "when default values are present for the object" do
    let(:nested_fields) do
      [
        stub("field", name: "label", enum_values: nil, default_value: "LABEL DEFAULT"),
        stub("field", name: "type", enum_values: %w[enum_1 enum_2 enum_3], default_value: "TYPE DEFAULT"),
        stub("field", name: "email_address", enum_values: nil, default_value: "EMAIL DEFAULT"),
      ]
    end

    it "renders the field with the default values" do
      render_inline(component)

      assert_selector "input[name=\"content_block/edition[details][nested][label]\"][value=\"LABEL DEFAULT\"]"
      assert_selector "input[name=\"content_block/edition[details][nested][type]\"][value=\"TYPE DEFAULT\"]"
      assert_selector "input[name=\"content_block/edition[details][nested][email_address]\"][value=\"EMAIL DEFAULT\"]"
    end
  end

  describe "when errors are present for the object" do
    before do
      content_block_edition.errors.add(:details_nested_label, "Label error")
      content_block_edition.errors.add(:details_nested_type, "Type error")
      content_block_edition.errors.add(:details_nested_email_address, "Email address error")
    end

    it "should show errors" do
      render_inline(component)

      assert_selector ".govuk-form-group.govuk-form-group--error", text: /Label/ do |form_group|
        form_group.assert_selector ".govuk-error-message", text: "Label error"
        form_group.assert_selector "input.govuk-input--error"
      end

      assert_selector ".govuk-form-group.govuk-form-group--error", text: /Type/ do |form_group|
        form_group.assert_selector ".govuk-error-message", text: "Type error"
        form_group.assert_selector "input.govuk-input--error"
      end

      assert_selector ".govuk-form-group.govuk-form-group--error", text: /Email address/ do |form_group|
        form_group.assert_selector ".govuk-error-message", text: "Email address error"
        form_group.assert_selector "input.govuk-input--error"
      end
    end
  end
end
