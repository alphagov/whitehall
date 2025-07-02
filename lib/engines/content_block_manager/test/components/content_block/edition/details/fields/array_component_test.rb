require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:field) { stub("field", name: "items", array_items:, is_required?: true) }
  let(:array_items) { { "type" => "string" } }
  let(:field_value) { nil }
  let(:object_title) { nil }

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent.new(
      content_block_edition:,
      field:,
      value: field_value,
      object_title:,
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
          expect_form_fields(fieldset, 0, "foo", 2)
        end

        component.assert_selector ".js-add-another__fieldset", text: /Item 2/ do |fieldset|
          expect_form_fields(fieldset, 1, "bar", 2)
        end

        component.assert_selector ".js-add-another__empty", text: /Item 3/ do |fieldset|
          expect_form_fields(fieldset, 2)
        end
      end
    end

    it "renders the hidden delete checkbox for each item" do
      render_inline component

      assert_selector ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
        fieldset.assert_selector "input[type='checkbox'][name='content_block/edition[details][items][][_destroy]']"
      end

      assert_selector ".js-add-another__fieldset", text: /Item 2/ do |fieldset|
        fieldset.assert_selector "input[type='checkbox'][name='content_block/edition[details][items][][_destroy]']"
      end
    end
  end

  describe "when an object title is provided" do
    let(:field_value) { %w[foo bar] }
    let(:object_title) { "field" }

    let(:latest_edition) { build(:content_block_edition, :contact, details:) }

    before do
      content_block_edition.document.stubs(:latest_edition).returns(latest_edition)
    end

    describe "when all items have previously been published" do
      let(:details) do
        {
          object_title => {
            field.name => field_value,
          },
        }
      end

      it "does not render any deletion checkboxes" do
        render_inline component

        assert_selector ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
          fieldset.assert_selector "input[type='hidden'][name='content_block/edition[details][items][][_destroy]'][value='0']", visible: false
          fieldset.assert_no_selector "input[type='checkbox'][name='content_block/edition[details][items][][_destroy]']"
        end

        assert_selector ".js-add-another__fieldset", text: /Item 2/ do |fieldset|
          fieldset.assert_selector "input[type='hidden'][name='content_block/edition[details][items][][_destroy]'][value='0']", visible: false
          fieldset.assert_no_selector "input[type='checkbox'][name='content_block/edition[details][items][][_destroy]']"
        end
      end
    end

    describe "one item has been previously published" do
      let(:details) do
        {
          object_title => {
            field.name => %w[foo],
          },
        }
      end

      it "renders a deletion checkbox for the unpublished item only" do
        render_inline component

        assert_selector ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
          fieldset.assert_selector "input[type='hidden'][name='content_block/edition[details][items][][_destroy]'][value='0']", visible: false
          fieldset.assert_no_selector "input[type='checkbox'][name='content_block/edition[details][items][][_destroy]']"
        end

        assert_selector ".js-add-another__fieldset", text: /Item 2/ do |fieldset|
          fieldset.assert_no_selector "input[type='hidden'][name='content_block/edition[details][items][][_destroy]'][value='0']", visible: false
          fieldset.assert_selector "input[type='checkbox'][name='content_block/edition[details][items][][_destroy]']"
        end
      end
    end
  end

private

  def expect_form_fields(fieldset, index, value = nil, form_group_count = 1)
    fieldset.assert_selector ".govuk-fieldset__legend", text: "Item #{index + 1}"
    fieldset.assert_selector ".govuk-form-group", count: form_group_count
    fieldset.assert_selector "input[value='#{value}']" unless value.nil?
    fieldset.assert_selector ".govuk-label", text: "Item"
  end
end
