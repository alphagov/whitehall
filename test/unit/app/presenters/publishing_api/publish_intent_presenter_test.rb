require "test_helper"

module PublishingApi
  class PublishIntentPresenterTest < ActiveSupport::TestCase
    test "it returns Whitehall as default publisher" do
      base_path = "/example-path"
      publish_timestamp = Time.zone.now.to_s

      presenter = PublishingApi::PublishIntentPresenter.new(base_path, publish_timestamp)
      expected_hash = {
        publish_time: publish_timestamp,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        routes: [{ path: base_path, type: "exact" }],
      }

      assert_equal presenter.as_json, expected_hash
    end

    test "it returns publishing app if provided" do
      base_path = "/example-path"
      publish_timestamp = Time.zone.now.to_s
      publishing_app = "example-publishing-app"

      presenter = PublishingApi::PublishIntentPresenter.new(base_path, publish_timestamp, publishing_app)
      expected_hash = {
        publish_time: publish_timestamp,
        publishing_app: "example-publishing-app",
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        routes: [{ path: base_path, type: "exact" }],
      }

      assert_equal presenter.as_json, expected_hash
    end
  end
end
