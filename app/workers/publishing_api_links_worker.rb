# Worker for batch sending of links to the publishing api
class PublishingApiLinksWorker < WorkerBase
  sidekiq_options queue: "bulk_republishing"

  def perform(edition_id)
    item = Edition.find(edition_id)
    content_id = item.content_id
    links = PublishingApiPresenters.presenter_for(item).links
    if links && !links.empty?
      Whitehall.publishing_api_v2_client.patch_links(content_id, {links: links})
    end
  end
end
