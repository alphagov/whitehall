module PublishingApi
  class WorldLocationNewsPagePresenter
    attr_accessor :world_location
    attr_accessor :update_type

    def initialize(world_location, update_type: nil)
      self.world_location = world_location
      self.update_type = update_type || "major"
    end

    def content_id
      find_or_create_content_id
    end

    def content
      content = BaseItemPresenter.new(
        world_location,
        title: title,
        need_ids: [],
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: description,
        details: {},
        document_type: "placeholder_world_location_news_page",
        public_updated_at: world_location.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "placeholder",
        base_path: path_for_news_page,
      )
      content.merge!(PayloadBuilder::Routes.for(path_for_news_page))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(world_location))
    end

    def links
      {}
    end

    def content_for_rummager
      {
        content_id: content_id,
        link: path_for_news_page,
        format: "world_location_news_page", # Used for the rummager document type
        title: title,
        description: description,
        indexable_content: description,
      }
    end

  private

    def path_for_news_page
      Whitehall.url_maker.polymorphic_path(world_location) + "/news"
    end

    def description
      "Updates, news and events from the UK government in #{world_location.name}"
    end

    def title
      world_location.title
    end

    def content_id_from_publishing_api
      Services.publishing_api.lookup_content_ids(base_paths: path_for_news_page)[path_for_news_page]
    end

    def find_or_create_content_id
      @content_id ||= (content_id_from_publishing_api || SecureRandom.uuid)
    end
  end
end
