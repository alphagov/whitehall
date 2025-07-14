require "test_helper"

class ContentBlockManager::ContentBlock::Schema::NestedFieldTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "NestedField" do
    it "can be created without passing a 'default_value' argument" do
      nested_field = ContentBlockManager::ContentBlock::Schema::Field::NestedField.new(
        name: "address_line_1",
        format: "string",
        enum_values: [],
      )

      assert_equal("address_line_1", nested_field.name)
      assert_equal("string", nested_field.format)
      assert_equal([], nested_field.enum_values)
      assert_nil(nested_field.default_value)
    end
  end
end
