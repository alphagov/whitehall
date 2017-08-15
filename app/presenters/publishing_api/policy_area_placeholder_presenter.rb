module PublishingApi
  # Note that "Policy Area" is the new name for "Topic".
  class PolicyAreaPlaceholderPresenter
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
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: nil,
        details: {},
        document_type: "policy_area",
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: schema_name,
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end


    def links
      LinksPresenter.new(item).extract([:organisations])
    end

  private

    def schema_name
      "placeholder"
    end
  end
end
