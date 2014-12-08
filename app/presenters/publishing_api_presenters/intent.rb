class PublishingApiPresenters::Intent
  attr_reader :item

  def initialize(item)
    @item = item
  end

  def base_path
    Whitehall.url_maker.public_document_path(item)
  end

  def as_json
    {
      base_path: base_path,
      publish_time: item.scheduled_publication,
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
