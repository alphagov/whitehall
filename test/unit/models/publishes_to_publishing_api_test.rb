require 'test_helper'

class PublishesToPublishingApiTest < ActiveSupport::TestCase
  class TestObject
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    def self.after_commit
    end

    def persisted?
      true
    end

    def content_id
      "26d638-e253-4b6c-a5e6-82122c441e50"
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
      if: :can_publish_to_publishing_api?
    )
    TestObject.stubs(:after_commit).with(
      :publish_gone_to_publishing_api,
      on: :destroy
    )
  end

  test "it hooks up publish_to_publishing_api correctly" do
    TestObject.expects(:after_commit).with(
      :publish_to_publishing_api,
      if: :can_publish_to_publishing_api?
    )
    include_module(TestObject.new)
  end

  test "it hooks up publish_gone_to_publishing_api correctly" do
    TestObject.expects(:after_commit).with(
      :publish_gone_to_publishing_api,
      on: :destroy
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

  test "publish gone to publishing api publishes gone async" do
    test_object = include_module(TestObject.new)
    Whitehall::PublishingApi.expects(:publish_gone_async)
      .with("26d638-e253-4b6c-a5e6-82122c441e50", nil, nil)
    test_object.publish_gone_to_publishing_api
  end

  test "defines and executes published callback when published" do
    Whitehall::PublishingApi.stubs(:publish_async)
    test_object = TestObject.new
    class << test_object
      include PublishesToPublishingApi
      set_callback :published, :test_published_handler

      def test_published_handler; end
    end

    test_object.expects(:test_published_handler)
    test_object.publish_to_publishing_api
  end

  test "defines and executes published_gone callback when published gone" do
    Whitehall::PublishingApi.stubs(:publish_gone_async)
    test_object = TestObject.new
    class << test_object
      include PublishesToPublishingApi
      set_callback :published_gone, :test_published_gone_handler

      def test_published_gone_handler; end
    end

    test_object.expects(:test_published_gone_handler)
    test_object.publish_gone_to_publishing_api
  end
end
