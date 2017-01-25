module PublishingApi
  class StatisticalDataSetPresenter
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
        document_type: "statistical_data_set",
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: item.rendering_app,
        schema_name: "statistical_data_set",
      )
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def links
      LinksPresenter.new(item).extract(
        %i(organisations policy_areas topics parent)
      )
    end

  private

    attr_reader :item

    def details
      {
        body: govspeak_renderer.govspeak_edition_to_html(item),
        change_history: item.change_history.as_json,
        emphasised_organisations: item.lead_organisations.map(&:content_id),
      }.tap do |details_hash|
        details_hash.merge!(PayloadBuilder::PoliticalDetails.for(item))
        details_hash.merge!(PayloadBuilder::FirstPublicAt.for(item))
      end
    end

    def govspeak_renderer
      @govspeak_renderer ||= Whitehall::GovspeakRenderer.new
    end
  end
end
