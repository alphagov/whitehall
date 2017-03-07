module PublishingApi
  class DocumentCollectionPresenter
    include UpdateTypeHelper

    attr_reader :update_type

    def initialize(item, update_type: nil)
      @item = item
      @update_type = update_type || default_update_type(item)
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItemPresenter.new(item).base_attributes
      content.merge!(
        description: item.summary,
        details: details,
        document_type: "document_collection",
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "document_collection",
        links: links,
      )
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def links
      links = LinksPresenter.new(item).extract(
        %i(organisations policy_areas topics related_policies parent)
      )
      links.merge!(documents: item.documents.map(&:content_id))
      links.merge!(PayloadBuilder::TopicalEvents.for(item))
    end

  private

    attr_reader :item

    def details
      {
        change_history: item.change_history.as_json,
        collection_groups: collection_groups,
        body: govspeak_renderer.govspeak_edition_to_html(item),
        emphasised_organisations: item.lead_organisations.map(&:content_id),
      }.tap do |details_hash|
        details_hash.merge!(PayloadBuilder::PoliticalDetails.for(item))
        details_hash.merge!(PayloadBuilder::FirstPublicAt.for(item))
      end
    end

    def collection_groups
      item.groups.map do |group|
        {
          title: group.heading,
          body: govspeak_renderer.govspeak_to_html(group.body),
          documents: group.documents.collect(&:content_id)
        }
      end
    end

    def govspeak_renderer
      @govspeak_renderer ||= Whitehall::GovspeakRenderer.new
    end
  end
end
