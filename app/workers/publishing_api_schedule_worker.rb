class PublishingApiScheduleWorker
  include Sidekiq::Worker

  def perform(base_path, publish_timestamp)
    publish_intent = build_publish_intent(base_path, publish_timestamp)

    Whitehall.publishing_api_client.put_intent(base_path, publish_intent)
  end

  def build_publish_intent(base_path, publish_timestamp)
    {
      publish_time: publish_timestamp,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      routes: [ { path: base_path, type: 'exact'} ]
    }
  end
end
