require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :email_address) }

  it "should render an input field with default parameters" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field: "email_address",
      ),
    )

    expected_name = "content_block/edition[details][email_address]"
    expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_email_address"

    assert_selector "label", text: "Email address"
    assert_selector "input[type=\"text\"][name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
  end

  it "should show the value when present" do
    content_block_edition.details = { "email_address": "example@example.com" }

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field: "email_address",
      ),
    )

    assert_selector 'input[value="example@example.com"]'
  end

  it "should show errors when present" do
    content_block_edition.errors.add(:details_email_address, "Some error goes here")

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field: "email_address",
      ),
    )

    assert_selector ".govuk-form-group--error"
    assert_selector ".govuk-error-message", text: "Some error goes here"
    assert_selector "input.govuk-input--error"
  end

  it "should allow a custom value" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field: "email_address",
        value: "some custom value",
      ),
    )

    assert_selector 'input[value="some custom value"]'
  end

  describe "hints" do
    it "should render hint text when a translation exists" do
      I18n.expects(:t).with("content_block_edition.details.hints.email_address", default: nil).returns("Some hint text")

      render_inline(
        ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
          content_block_edition:,
          field: "email_address",
          value: "some custom value",
        ),
      )

      assert_selector ".govuk-hint", text: "Some hint text"
    end

    it "should use the id_suffix for the hint text when provided" do
      I18n.expects(:t).with("content_block_edition.details.hints.my.suffix", default: nil).returns("Some hint text")

      render_inline(
        ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
          content_block_edition:,
          field: "email_address",
          value: "some custom value",
          id_suffix: "my_suffix",
        ),
      )

      assert_selector ".govuk-hint", text: "Some hint text"
    end
  end

  describe "when field is an array" do
    it "renders with the correct name" do
      render_inline(
        ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
          content_block_edition:,
          label: "foo",
          field: %w[foo bar],
        ),
      )

      expected_name = "content_block/edition[details][foo][bar]"

      assert_selector "input[type=\"text\"][name=\"#{expected_name}\"]"
    end
  end
end
