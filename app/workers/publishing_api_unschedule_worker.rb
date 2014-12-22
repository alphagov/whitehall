class PublishingApiUnscheduleWorker
  include Sidekiq::Worker

  def perform(base_path)
    Whitehall.publishing_api_client.destroy_intent(base_path)
  end
end
