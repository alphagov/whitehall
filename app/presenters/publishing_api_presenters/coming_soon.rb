class PublishingApiPresenters::ComingSoon
  attr_reader :edition, :update_type

  def initialize(edition, options = {})
    @edition = edition
    @update_type = options[:update_type] || default_update_type
  end

  def base_path
    Whitehall.url_maker.public_document_path(edition)
  end

  def as_json
    {
      base_path: base_path,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      update_type: update_type,
      details: {
        publish_time: edition.scheduled_publication,
      },
      routes: [
        {
          path: base_path,
          type: "exact"
        }
      ]
    }
  end

private

  def default_update_type
    'major'
  end
end

