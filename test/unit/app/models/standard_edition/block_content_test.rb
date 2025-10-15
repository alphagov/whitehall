require "test_helper"

class BlockContentTest < ActiveSupport::TestCase
  test "raises exception when encountering a validation rule with no definition" do
    schema = {
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
        },
      },
      "required" => %w[test_attribute],
      "validations" => {
        "made_up_validation_rule" => {
          "attributes" => %w[test_attribute],
        },
      },
    }
    page = StandardEdition::BlockContent.new(schema, ConfigurableContentBlocks::Path.new)

    error = assert_raises(ArgumentError) do
      page.valid_instance_of_document_type_attributes
    end
    assert_equal "undefined validator type made_up_validation_rule", error.message
  end

  test "maps 'presence' validation to ActiveModel::Validations::PresenceValidator" do
    schema = {
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
        },
      },
      "required" => %w[test_attribute],
      "validations" => {
        "presence" => {
          "attributes" => %w[test_attribute],
        },
      },
    }
    page = StandardEdition::BlockContent.new(schema, ConfigurableContentBlocks::Path.new)

    page.attributes = { "test_attribute" => "" }
    assert_not page.valid?
    assert_not page.errors.where("test_attribute", :blank).empty?
  end

  test "maps 'length' validation to ActiveModel::Validations::LengthValidator" do
    schema = {
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
        },
      },
      "required" => %w[test_attribute],
      "validations" => {
        "length" => {
          "attributes" => %w[test_attribute],
          "maximum" => 5,
        },
      },
    }
    page = StandardEdition::BlockContent.new(schema, ConfigurableContentBlocks::Path.new)

    page.attributes = { "test_attribute" => "exceeds max length" }
    assert_not page.valid?
    assert_not page.errors.where("test_attribute", :too_long, count: 5).empty?
  end

  test "maps 'safe_html' validation to SafeHtmlValidator" do
    Whitehall.stubs(:skip_safe_html_validation).returns(false)

    schema = {
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
          "format" => "govspeak",
        },
      },
      "required" => %w[test_attribute],
      "validations" => {
        "safe_html" => {
          "attributes" => %w[test_attribute],
        },
      },
    }
    page = StandardEdition::BlockContent.new(schema, ConfigurableContentBlocks::Path.new)

    page.attributes = { "test_attribute" => "<script>alert('MALICIOUS')</script>" }
    assert_not page.valid?
    assert_not page.errors.where("test_attribute", :unsafe_html).empty?
  end
end
