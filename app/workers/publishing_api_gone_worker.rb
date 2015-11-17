require "securerandom"

class PublishingApiGoneWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(base_path, edition_content_id)
    Whitehall.publishing_api_client.put_content_item(base_path, gone_item_for(base_path, edition_content_id))
  end

private

  def gone_item_for(base_path, edition_content_id)
    {
      content_id: SecureRandom.uuid,
      format: 'gone',
      publishing_app: 'whitehall',
      update_type: 'major',
      routes: [{path: base_path, type: 'exact'}],
      links: {
        can_be_replaced_by: [edition_content_id],
      },
    }
  end
end
