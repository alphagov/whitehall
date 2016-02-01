require 'test_helper'
require 'sidekiq/testing'

class PublishesToPublishingApiTest < ActiveSupport::TestCase
  class TestObject
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    def self.after_commit
    end

    def persisted?
      true
    end

    def search_link
      "test_link"
    end
  end

  def include_module(object)
    class << object
      include PublishesToPublishingApi
    end
    object
  end

  setup do
    TestObject.stubs(:after_commit).with(
      :publish_to_publishing_api,
      { if: :can_publish_to_publishing_api? }
    )
    TestObject.stubs(:after_commit).with(
      :publish_gone_to_publishing_api,
      { on: :destroy }
    )
  end

  test "it hooks up publish_to_publishing_api correctly" do
    TestObject.expects(:after_commit).with(
      :publish_to_publishing_api,
      { if: :can_publish_to_publishing_api? }
    )
    include_module(TestObject.new)
  end

  test "it hooks up publish_gone_to_publishing_api correctly" do
    TestObject.expects(:after_commit).with(
      :publish_gone_to_publishing_api,
      { on: :destroy }
    )
    include_module(TestObject.new)
  end

  test "can publish to publishing api returns true when object persisted" do
    test_object = include_module(TestObject.new)
    assert test_object.can_publish_to_publishing_api?
  end

  test "can publish to publishing api returns false when object not persisted" do
    test_object = include_module(TestObject.new)
    test_object.stubs(persisted?: false)
    refute test_object.can_publish_to_publishing_api?
  end

  test "publish to publishing api publishes async" do
    test_object = include_module(TestObject.new)
    Whitehall::PublishingApi.expects(:publish_async).with(test_object)
    test_object.publish_to_publishing_api
  end

  test "publish gone to publishing api publishes async" do
    test_object = include_module(TestObject.new)
    Whitehall::PublishingApi.expects(:publish_gone).with("test_link")
    test_object.publish_gone_to_publishing_api
  end
end
