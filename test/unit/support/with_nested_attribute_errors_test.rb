require "test_helper"

class WithNestedAttributeErrorsTest < ActiveSupport::TestCase
  class TestClass
    include ActiveModel::API
    include WithNestedAttributeErrors
    attr_accessor :name
  end

  setup do
    @obj = TestClass.new
  end

  test "prevents NoMethodError when Rails processes dotted attribute errors" do
    @obj.errors.add(:"social_media_links.0.url", "cannot be blank")
    assert_nothing_raised { @obj.errors.full_messages }
  end

  test "returns nil for dotted attribute names and responds to them" do
    assert_nil @obj.public_send(:"social_media_links.0.url")
    assert @obj.respond_to?(:"social_media_links.0.url")
  end

  test "raises NoMethodError for non-dotted unknown methods and does not respond to them" do
    assert_raises(NoMethodError) { @obj.public_send(:nonexistent_method) }
    assert_not @obj.respond_to?(:nonexistent_method)
  end

  test "does not affect respond_to? for known methods" do
    assert @obj.respond_to?(:name)
  end
end
