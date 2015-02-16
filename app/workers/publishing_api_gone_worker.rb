class PublishingApiGoneWorker
  include Sidekiq::Worker

  def perform(base_path)
    Whitehall.publishing_api_client.put_content_item(base_path, gone_item_for(base_path))
  end

private

  def gone_item_for(base_path)
    {
      format: 'gone',
      publishing_app: 'whitehall',
      update_type: 'major',
      routes: [{path: base_path, type: 'exact'}],
    }
  end
end
