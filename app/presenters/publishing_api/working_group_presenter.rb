module PublishingApi
  class WorkingGroupPresenter
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
      {}
    end

  private

    def schema_name
      "working_group"
    end

    def description
      item.summary # This is deliberately the 'wrong' way around
    end

    def details
      {
        email: item.email,
        body: body,
      }
    end

    def body
      # It looks 'wrong' using the description as the body, but it isn't
      if item.description.present?
        Whitehall::GovspeakRenderer.new.govspeak_with_attachments_to_html(item.description, item.attachments, item.email)
      else
        ""
      end
    end
  end
end
