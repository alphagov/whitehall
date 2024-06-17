module PublishingApi
  class TopicalEventAboutPagePresenter
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
        description: item.summary,
        base_path:,
        details:,
        document_type: schema_name,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name:,
      )
      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def links
      { parent: [item.topical_event.content_id] }
    end

  private

    def schema_name
      "topical_event_about_page"
    end

    def base_path
      item.base_path
    end

    def details
      {
        body:,
        read_more: item.read_more_link_text,
      }
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_to_html(item.body)
    end
  end
end
