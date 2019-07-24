# Worker for batch sending of links to the publishing api
class PublishingApiLinksWorker < WorkerBase
  sidekiq_options queue: "bulk_republishing"

  def perform(edition_id)
    item = Edition.find(edition_id)
    if item.locked?
      raise RuntimeError, "Cannot send a locked document to the Publishing API"
    end

    content_id = item.content_id
    links = PublishingApiPresenters.presenter_for(item).links

    if links && !links.empty?
      Services.publishing_api.patch_links(
        content_id,
        links: links,
        bulk_publishing: true
      )
    end
  end
end
