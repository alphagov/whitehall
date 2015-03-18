class PublishingApiComingSoonWorker
  include Sidekiq::Worker

  def perform(edition_id, locale)
    edition = Edition.find(edition_id)
    coming_soon = PublishingApiPresenters::ComingSoon.new(edition, locale)

    base_path = Whitehall.url_maker.public_document_path(edition, locale: locale)
    Whitehall.publishing_api_client.put_content_item(base_path, coming_soon.as_json)
  end
end
