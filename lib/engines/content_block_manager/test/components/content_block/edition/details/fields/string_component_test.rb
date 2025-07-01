require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:field) { stub("field", name: "email_address", is_required?: true) }

  it "should render an input field with default parameters" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field:,
      ),
    )

    expected_name = "content_block/edition[details][email_address]"
    expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_email_address"

    assert_selector "label", text: "Email address"
    assert_selector "input[type=\"text\"][name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
  end

  it "should show optional label when field is optional" do
    optional_field = stub("field", name: "email_address", is_required?: false)

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field: optional_field,
      ),
    )

    assert_selector "label", text: "Email address (optional)"
  end

  it "should show the value when provided" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field:,
        value: "example@example.com",
      ),
    )

    assert_selector 'input[value="example@example.com"]'
  end

  it "should show the value from an embedded object" do
    content_block_edition.details = { "description": "example@example.com" }
  end

  it "should show errors when present" do
    content_block_edition.errors.add(:details_email_address, "Some error goes here")

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field:,
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
        field:,
        value: "some custom value",
      ),
    )

    assert_selector 'input[value="some custom value"]'
  end

  it "should render hint text when a translation exists" do
    I18n.expects(:t).with("content_block_edition.details.labels.email_address", default: "Email address").returns(nil)
    I18n.expects(:t).with("content_block_edition.details.hints.email_address", default: nil).returns("Some hint text")

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field:,
        value: "some custom value",
      ),
    )

    assert_selector ".govuk-hint", text: "Some hint text"
  end

  describe "when there is a translation for a field label" do
    it "should return the translation" do
      I18n.expects(:t).with("content_block_edition.details.hints.email_address", default: nil).returns("Some hint text")

      I18n.expects(:t).with("content_block_edition.details.labels.email_address", default: "Email address").returns("Email address translated")

      render_inline(
        ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
          content_block_edition:,
          field:,
        ),
      )

      assert_selector "label", text: "Email address translated"
    end
  end

  describe "when a subschema is present" do
    let(:subschema) { stub(:schema, block_type: "my_suffix") }

    let(:component) do
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field:,
        value: "some custom value",
        subschema:,
      )
    end

    it "should generate the correct name and ID" do
      render_inline component

      expected_name = "content_block/edition[details][my_suffix][email_address]"
      expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_my_suffix_email_address"

      assert_selector "input[type=\"text\"][name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
    end

    it "should use the subschema for the hint text when provided" do
      I18n.expects(:t).with("content_block_edition.details.labels.my_suffix.email_address", default: "Email address").returns(nil)
      I18n.expects(:t).with("content_block_edition.details.hints.my_suffix.email_address", default: nil).returns("Some hint text")

      render_inline component

      assert_selector ".govuk-hint", text: "Some hint text"
    end
  end
end
