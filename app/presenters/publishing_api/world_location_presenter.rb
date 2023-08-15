module PublishingApi
  class WorldLocationPresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.name,
        update_type:,
      ).base_attributes

      content.merge!(
        description: nil,
        details: {},
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        schema_name: "world_location",
      )
      if item.international_delegation?
        content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      end
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {}
    end
  end
end
