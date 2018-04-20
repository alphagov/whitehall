module PublishingApi
  class PersonPresenter
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
        details: details,
        document_type: "person",
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "person",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      {}
    end

    def details
      {}.tap do |hash|
        if item.image_url(:s465)
          hash[:image] = { url: item.image_url(:s465), alt_text: item.name }
        end
      end
    end
  end
end
