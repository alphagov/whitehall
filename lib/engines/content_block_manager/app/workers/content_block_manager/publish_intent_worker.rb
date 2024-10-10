require "sidekiq/api"

module ContentBlockManager
  class PublishIntentWorker < WorkerBase
    sidekiq_options queue: :content_block_publishing

    def perform(base_path, publishing_app, publish_timestamp)
      publish_timestamp = Time.zone.parse(publish_timestamp)
      publish_intent = PublishingApi::PublishIntentPresenter.new(base_path, publish_timestamp, publishing_app)

      Services.publishing_api.put_intent(base_path, publish_intent.as_json)
    end
  end
end
