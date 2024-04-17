module PublishingApi
  class WorldwideOrganisationPagePresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.title,
        update_type:,
      ).base_attributes

      content.merge!(
        details: {
          body: Whitehall::GovspeakRenderer.new.govspeak_with_attachments_to_html(item.body, item.attachments),
        },
        description: item.summary,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "worldwide_corporate_information_page",
        document_type:,
        links: edition_links,
      )

      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def edition_links
      {
        parent: [item.edition.content_id],
        worldwide_organisation: [item.edition.content_id],
      }
    end

    def links
      {}
    end

    def document_type
      item.display_type_key
    end
  end
end
