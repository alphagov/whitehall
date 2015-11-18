class PublishingApiPresenters::PublishIntent
  def initialize(base_path, publish_timestamp)
    @base_path = base_path
    @publish_timestamp = publish_timestamp
  end

  def as_json
    {
      publish_time: @publish_timestamp,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      routes: [{ path: @base_path, type: 'exact' }],
    }
  end
end
