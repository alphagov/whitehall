module PublishingApi
  class LandingPagePresenter
    include Presenters::PublishingApi::UpdateTypeHelper

    attr_reader :update_type

    def initialize(item, update_type: nil)
      @item = item
      @update_type = update_type || default_update_type(item)
    end

    delegate :content_id, to: :item

    def content
      {}.tap do |content|
        content.merge!(BaseItemPresenter.new(item, update_type:).base_attributes)
        content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
        content.merge!(
          description: item.summary,
          document_type:,
          public_updated_at: item.public_timestamp || item.updated_at,
          rendering_app: item.rendering_app,
          schema_name: "landing_page",
          details:,
          links: edition_links,
          auth_bypass_ids: [item.auth_bypass_id],
        )
        content.merge!(PayloadBuilder::AccessLimitation.for(item))
        content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
      end
    end

    def links
      {}
    end

    def edition_links
      links = PayloadBuilder::Links.for(item).extract(%i[organisations])
      links[:documents] = item.content_ids.uniq
      links
    end

    def document_type
      "landing_page"
    end

  private

    attr_reader :item

    def details
      body = YAML.load(item.body, permitted_classes: [Date])
      {
        blocks: body.fetch("blocks"),
        collection_groups:,
      }
    end

    def collection_groups
      item.groups.map do |group|
        {
          title: group.heading,
          body: govspeak_renderer.govspeak_to_html(group.body),
          documents: group.content_ids,
        }
      end
    end

    def govspeak_renderer
      @govspeak_renderer ||= Whitehall::GovspeakRenderer.new
    end
  end
end
