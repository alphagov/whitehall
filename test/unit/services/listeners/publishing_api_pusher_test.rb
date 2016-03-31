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

    test "update_draft_translation saves draft translation" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:save_draft_translation_async).with(edition, 'en')
      PublishingApiPusher.new(edition).push(event: "update_draft_translation", options: { locale: "en" })
    end

    test "withdraw republishes" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:republish_document_async).with(edition.document)
      PublishingApiPusher.new(edition).push(event: "withdraw")
    end

    test "unpublish publishes the unpublishing" do
      edition = build(:unpublished_publication)
      Whitehall::PublishingApi.expects(:publish_async).with(edition.unpublishing)
      PublishingApiPusher.new(edition).push(event: "unpublish")
    end

    test "force_schedule schedules" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:schedule_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "force_schedule")
    end

    test "schedule schedules" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:schedule_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "schedule")
    end

    test "unschedule unschedules" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:unschedule_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "unschedule")
    end

    test "delete discards draft" do
      edition = build(:publication)
      Whitehall::PublishingApi.expects(:discard_draft_async).with(edition)
      PublishingApiPusher.new(edition).push(event: "delete")
    end
  end
end
