# A publish intent is sent to the Publishing API to indicate that a document is
# due to be published at a given set of routes at a given time.
#
# See [content_store](https://github.com/alphagov/content-store) for more
# details on publish intents.
class PublishingApiPresenters::PublishIntent
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def base_path
    Whitehall.url_maker.public_document_path(edition)
  end

  def as_json
    {
      base_path: base_path,
      publish_time: edition.scheduled_publication,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      routes: [
        {
          path: base_path,
          type: "exact"
        }
      ]
    }
  end
end
