class PublishingApiUnscheduleWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(base_path)
    Whitehall.publishing_api_client.destroy_intent(base_path)
  end
end
