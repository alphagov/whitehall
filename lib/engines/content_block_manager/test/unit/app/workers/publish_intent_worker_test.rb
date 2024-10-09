require "test_helper"

class ContentBlockManager::PublishIntentWorkerTest < ActiveSupport::TestCase
  test "#perform adds a publishing intent to the Publishing API" do
    base_path = "/base-path"
    timestamp = Time.zone.now.to_s
    publishing_app = "publisher"
    publish_intent = { foo: "bar" }

    PublishingApi::PublishIntentPresenter.expects(:new).with(base_path, timestamp, publishing_app).once.returns(publish_intent)
    Services.publishing_api.expects(:put_intent).once.with(base_path, publish_intent.as_json)
    ContentBlockManager::PublishIntentWorker.new.perform(base_path, publishing_app, timestamp)
  end
end
