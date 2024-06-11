require "test_helper"

class ObjectStore::ObjectTest < ActiveSupport::TestCase
  test "should create" do
    object = ObjectStore::Object.new
    object.title = "foo"

    assert_equal object.title, "foo"
  end
end
