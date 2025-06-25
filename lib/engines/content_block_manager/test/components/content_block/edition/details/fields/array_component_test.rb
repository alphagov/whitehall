require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:field) { stub("field", name: "items", array_items:, is_required?: true) }
  let(:array_items) { { "type" => "string" } }
  let(:field_value) { nil }

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent.new(
      content_block_edition:,
      field:,
      value: field_value,
    )
  end

  describe "when there are no items present" do
    it "renders with one empty item and a template" do
      render_inline component

      assert_selector ".gem-c-add-another" do |component|
        component.assert_selector ".js-add-another__fieldset", count: 1
        component.assert_selector ".js-add-another__empty", count: 1

        component.assert_selector ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
          expect_form_fields(fieldset, 0)
        end

        component.assert_selector ".js-add-another__empty", text: /Item 2/ do |fieldset|
          expect_form_fields(fieldset, 1)
        end
      end
    end
  end

  describe "when there are items present" do
    let(:field_value) { %w[foo bar] }

    it "renders a fieldset for each item and a template" do
      render_inline component

      assert_selector ".gem-c-add-another" do |component|
        component.assert_selector ".js-add-another__fieldset", count: 2
        component.assert_selector ".js-add-another__empty", count: 1

        component.assert_selector ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
          expect_form_fields(fieldset, 0, "foo")
        end

        component.assert_selector ".js-add-another__fieldset", text: /Item 2/ do |fieldset|
          expect_form_fields(fieldset, 1, "bar")
        end

        component.assert_selector ".js-add-another__empty", text: /Item 3/ do |fieldset|
          expect_form_fields(fieldset, 2)
        end
      end
    end
  end

private

  def expect_form_fields(fieldset, index, value = nil)
    fieldset.assert_selector ".govuk-fieldset__legend", text: "Item #{index + 1}"
    fieldset.assert_selector ".govuk-form-group", count: 1
    fieldset.assert_selector ".govuk-form-group" do |form_group|
      form_group.assert_selector "input[value='#{value}']" unless value.nil?
      form_group.assert_selector ".govuk-label", text: "Item"
    end
  end
end
