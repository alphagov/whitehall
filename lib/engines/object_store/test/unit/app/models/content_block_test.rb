require "test_helper"

class ObjectStore::ContentBlockTest < ActiveSupport::TestCase
  test "should create" do
    block = ObjectStore::ContentBlock.new
    block.title = "foo"

    assert_equal block.title, "foo"
  end
end
