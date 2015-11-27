class PublishingApiComingSoonWorker < PublishingApiWorker
  def perform(edition_id, locale)
    edition = Edition.find(edition_id)
    coming_soon = PublishingApiPresenters::ComingSoon.new(edition, locale)
    send_item(coming_soon.as_json)
  end
end
