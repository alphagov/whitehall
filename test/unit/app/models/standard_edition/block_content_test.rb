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
end
