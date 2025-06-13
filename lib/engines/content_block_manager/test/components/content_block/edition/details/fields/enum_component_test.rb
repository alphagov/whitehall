require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:field) { stub("field", name: "something", is_required?: true) }

  describe "when there is no default value" do
    it "should render a select field with given parameters" do
      render_inline(
        ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
          content_block_edition:,
          field:,
          enum: ["a week", "a month"],
        ),
      )

      expected_name = "content_block/edition[details][something]"
      expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

      assert_selector "label", text: "Something"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a week\"]", text: "a week"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a month\"]", text: "a month"
    end

    it "should show an option as selected when value is given" do
      render_inline(
        ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
          content_block_edition:,
          field:,
          enum: ["a week", "a month"],
          value: "a week",
        ),
      )

      expected_name = "content_block/edition[details][something]"
      expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

      assert_selector "label", text: "Something"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a week\"][selected]", text: "a week"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a month\"]", text: "a month"
    end
  end

  describe "when there is a default value" do
    it "should render a select field with given parameters" do
      render_inline(
        ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
          content_block_edition:,
          field:,
          enum: ["a week", "a month"],
          default: "a month",
        ),
      )

      expected_name = "content_block/edition[details][something]"
      expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

      assert_selector "label", text: "Something"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a week\"]", text: "a week"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a month\"][selected]", text: "a month"
    end

    it "should show an option as selected when value is given" do
      render_inline(
        ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
          content_block_edition:,
          field:,
          enum: ["a week", "a month"],
          value: "a week",
          default: "a month",
        ),
      )

      expected_name = "content_block/edition[details][something]"
      expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

      assert_selector "label", text: "Something"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a week\"][selected]", text: "a week"
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a month\"]", text: "a month"
    end
  end

  it "should show errors when present" do
    content_block_edition.errors.add(:details_something, "Some error goes here")

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
        content_block_edition:,
        field:,
        enum: [],
      ),
    )

    assert_selector ".govuk-form-group--error"
    assert_selector ".govuk-error-message", text: "Some error goes here"
    assert_selector "select.govuk-select--error"
  end
end
