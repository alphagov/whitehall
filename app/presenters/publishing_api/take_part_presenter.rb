module PublishingApi
  class TakePartPresenter
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
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: item.summary,
        details: details,
        document_type: schema_name,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: schema_name,
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      LinksPresenter.new(item).extract([
        :policy_areas,
      ])
    end

  private

    def schema_name
      "take_part"
    end

    def details
      {
        body: body,
        image: {
          url: item.image_url(:s300),
          alt_text: item.image_alt_text,
        }
      }
    end

    def description
      item.summary
    end

    def public_updated_at
      item.updated_at
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_to_html(item.body)
    end

    def rendering_app
      Whitehall::RenderingApp::GOVERNMENT_FRONTEND
    end
  end
end
