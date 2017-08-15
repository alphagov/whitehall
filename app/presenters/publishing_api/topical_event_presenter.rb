module PublishingApi
  class TopicalEventPresenter
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
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "placeholder",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      LinksPresenter.new(item).extract([:organisations])
    end

  private

    def details
      {}.tap do |details|
        details[:start_date] = item.start_date.to_datetime if item.start_date
        details[:end_date] = item.end_date.to_datetime if item.end_date
      end
    end
  end
end
