module PublishingApi
  class TopicalEventAboutPagePresenter
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
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: item.summary,
        base_path: base_path,
        details: details,
        document_type: schema_name,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: schema_name,
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
      Whitehall.url_maker.topical_event_about_pages_path(item.topical_event)
    end

    def details
      {
        body: body,
        read_more: item.read_more_link_text
      }
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_to_html(item.body)
    end
  end
end
