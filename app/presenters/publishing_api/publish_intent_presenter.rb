module PublishingApi
  class PublishIntentPresenter
    def initialize(base_path, publish_timestamp)
      @base_path = base_path
      @publish_timestamp = publish_timestamp
    end

    def as_json
      {
        publish_time: @publish_timestamp,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        routes: [{ path: @base_path, type: "exact" }],
      }
    end
  end
end
