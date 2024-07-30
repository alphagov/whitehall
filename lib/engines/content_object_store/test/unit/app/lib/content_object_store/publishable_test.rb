require "test_helper"

class ContentObjectStore::PublishableTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  class PublishableTestClass
    include ContentObjectStore::Publishable
  end

  test "it raises an error if a block isn't passed since changes need to be made locally" do
    anything = Object.new
    test_instance = PublishableTestClass.new

    assert_raises ArgumentError, "Local database changes not given" do
      test_instance.publish_with_rollback(
        schema: anything, title: anything, details: anything,
      )
    end
  end
end
