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
      "validations" => {
        "made_up_validation_rule" => {
          "attributes" => %w[test_attribute],
        },
      },
    }
    page = StandardEdition::BlockContent.new(schema, ConfigurableContentBlocks::Path.new)

    error = assert_raises(ArgumentError) do
      page.attributes = { "test_attribute" => "" }
      page.valid?
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
end
