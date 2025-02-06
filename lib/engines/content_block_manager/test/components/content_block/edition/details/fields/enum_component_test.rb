require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :email_address) }

  it "should render an select field with default parameters" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
        content_block_edition:,
        field: "something",
        enum: %w[item_1 item_2],
      ),
    )

    expected_name = "content_block/edition[details][something]"
    expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

    assert_selector "label", text: "Something"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"item_1\"]", text: "Item 1"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"item_2\"]", text: "Item 2"
  end

  it "should show an option as selected when value is given" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
        content_block_edition:,
        field: "something",
        enum: %w[item_1 item_2],
        value: "item_1",
      ),
    )

    expected_name = "content_block/edition[details][something]"
    expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

    assert_selector "label", text: "Something"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"item_1\"][selected]", text: "Item 1"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"item_2\"]", text: "Item 2"
  end

  it "should show errors when present" do
    content_block_edition.errors.add(:details_something, "Some error goes here")

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
        content_block_edition:,
        field: "something",
        enum: [],
      ),
    )

    assert_selector ".govuk-form-group--error"
    assert_selector ".govuk-error-message", text: "Some error goes here"
    assert_selector "select.govuk-select--error"
  end
end
