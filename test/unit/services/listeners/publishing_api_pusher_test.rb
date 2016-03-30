require 'test_helper'

module ServiceListeners
  class PublishingApiPusherTest < ActiveSupport::TestCase
    test "saves draft async for update_draft" do
      edition = build(:draft_publication)
      Whitehall::PublishingApi.expects(:save_draft_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "update_draft")
    end

    test "publish publishes" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:publish_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "publish")
    end

    test "force_publish publishes" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:publish_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "force_publish")
    end
  end
end
