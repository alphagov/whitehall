module PublishingApi
  class WorldIndexPresenter
    attr_accessor :update_type

    def initialize(update_type: nil)
      self.update_type = update_type || "major"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "Help and services around the world",
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        details:,
        document_type: "world_index",
        public_updated_at: Time.zone.now,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "world_index",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def details
      {
        world_locations: format_locations(WorldLocation.world_location),
        international_delegations: format_locations(WorldLocation.international_delegation),
      }
    end

    def links
      {}
    end

    def content_id
      "369729ba-7776-4123-96be-2e3e98e153e1"
    end

    def base_path
      "/world"
    end

  private

    def format_locations(locations)
      locations.map do |location|
        {
          name: location.name,
          slug: location.slug,
          active: location.active,
        }
      end
    end
  end
end
