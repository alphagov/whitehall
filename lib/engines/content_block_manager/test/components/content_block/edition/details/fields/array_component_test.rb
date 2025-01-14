require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition) }
  let(:properties) { %w[foo bar] }

  it "renders fields when there are no items" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent.new(
        content_block_edition:,
        field: "my_array",
        properties:,
      ),
    )

    assert_selector "div.govuk-form-group##{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_my_array"

    properties.each do |property|
      expected_name = "content_block/edition[details[[my_array][][#{property}]]]"
      expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_my_array_0_#{property}"

      assert_selector "label", text: property.humanize
      assert_selector "input[type=\"text\"][name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
    end
  end

  it "renders fields when there is data present" do
    content_block_edition.details = {
      "my_array" => [
        { "foo" => "Foo 1", "bar" => "Bar 2" },
        { "foo" => "Foo 2", "bar" => "Bar 2" },
      ],
    }

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent.new(
        content_block_edition:,
        field: "my_array",
        properties:,
      ),
    )

    content_block_edition.details["my_array"].each_with_index do |item, index|
      item.each do |property, value|
        expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_my_array_#{index}_#{property}"
        assert_selector "input[type=\"text\"][id=\"#{expected_id}\"][value=\"#{value}\"]"
      end
    end
  end

  it "shows an error when an error is present" do
    content_block_edition.errors.add(:details_my_array, "Some error goes here")

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::ArrayComponent.new(
        content_block_edition:,
        field: "my_array",
        properties:,
      ),
    )

    assert_selector "div.govuk-form-group--error##{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_my_array"
    assert_selector ".govuk-error-message", text: "Some error goes here"
  end
end
