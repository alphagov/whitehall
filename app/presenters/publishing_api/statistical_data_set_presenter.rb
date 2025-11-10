module PublishingApi
  class StatisticalDataSetPresenter
    include Presenters::PublishingApi::UpdateTypeHelper
    include GovspeakHelper

    attr_reader :update_type

    def initialize(item, update_type: nil)
      @item = item
      @update_type = update_type || default_update_type(item)
    end

    delegate :content_id, to: :item

    def content
      BaseItemPresenter
        .new(item, update_type:)
        .base_attributes
        .merge(PayloadBuilder::AccessLimitation.for(item))
        .merge(PayloadBuilder::PublicDocumentPath.for(item))
        .merge(PayloadBuilder::FirstPublishedAt.for(item))
        .merge(
          description: item.summary,
          details:,
          document_type:,
          public_updated_at: item.public_timestamp || item.updated_at,
          rendering_app: item.rendering_app,
          schema_name: "statistical_data_set",
          auth_bypass_ids: [item.auth_bypass_id],
        )
    end

    def links
      PayloadBuilder::Links.for(item).extract(
        %i[organisations government],
      )
    end

    def document_type
      "statistical_data_set"
    end

  private

    attr_reader :item

    def details
      {
        body: govspeak_edition_to_html(item),
        change_history: item.change_history.as_json,
      }.tap do |details_hash|
        details_hash.merge!(PayloadBuilder::PoliticalDetails.for(item))
        details_hash.merge!(PayloadBuilder::FirstPublicAt.for(item))
        details_hash.merge!(PayloadBuilder::Attachments.for(item))
        details_hash.merge!(PayloadBuilder::BodyHeadings.for(item))
        details_hash.merge!(PayloadBuilder::EmphasisedOrganisations.for(item))
      end
    end
  end
end
