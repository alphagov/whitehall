require "test_helper"

class ContentObjectStore::PublishIntentWorkerTest < ActiveSupport::TestCase
  test "#perform adds a publishing intent to the Publishing API" do
    base_path = "/base-path"
    timestamp = Time.zone.now.to_s
    publish_intent = { foo: "bar" }

    PublishingApi::PublishIntentPresenter.expects(:new).with(base_path, timestamp).once.returns(publish_intent)
    Services.publishing_api.expects(:put_intent).once.with(base_path, publish_intent.as_json)
    ContentObjectStore::PublishIntentWorker.new.perform(base_path, timestamp)
  end
end