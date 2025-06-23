require "test_helper"
class FlexiblePageContentBlocks::FactoryTest < ActiveSupport::TestCase
  test "it raises an error if the block type does not exist" do
    error = assert_raises do
      FlexiblePageContentBlocks::Factory.build("missing", "format")
    end
    assert_equal "No block is defined for the missing type format format", error.message
  end

  test "it raises an error if the block format does not exist" do
    error = assert_raises do
      FlexiblePageContentBlocks::Factory.build("string", "missing")
    end
    assert_equal "No block is defined for the string type missing format", error.message
  end
end
