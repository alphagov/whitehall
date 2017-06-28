module PublishingApi
  class WorldLocationPresenter
    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.name,
        need_ids: [],
      ).base_attributes

      content.merge!(
        description: nil,
        details: {},
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "world_location",
      )
      if international_delegation?
        content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      end
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {}
    end

  private

    def international_delegation?
      item.world_location_type_id == WorldLocationType::InternationalDelegation.id
    end
  end
end
