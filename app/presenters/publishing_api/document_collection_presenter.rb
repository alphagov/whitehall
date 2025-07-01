module PublishingApi
  class DocumentCollectionPresenter
    include Presenters::PublishingApi::UpdateTypeHelper

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
          schema_name: "document_collection",
          links: edition_links,
          auth_bypass_ids: [item.auth_bypass_id],
        )
    end

    def links
      # TODO: Previously, this presenter was sending all links to the
      # Publishing API at both the document level, and edition
      # level. This is probably redundant, and hopefully can be
      # improved.
      edition_links
    end

    def edition_links
      links = PayloadBuilder::Links.for(item).extract(
        %i[organisations government],
      )
      links[:documents] = item.content_ids.uniq
      links[:taxonomy_topic_email_override] = [item.taxonomy_topic_email_override] if item.taxonomy_topic_email_override
      links.merge!(PayloadBuilder::TopicalEvents.for(item))
    end

    def document_type
      "document_collection"
    end

  private

    attr_reader :item

    def details
      {
        change_history: item.change_history.as_json,
        collection_groups:,
        body: govspeak_renderer.govspeak_edition_to_html(item),
        emphasised_organisations: item.lead_organisations.map(&:content_id),
      }.tap do |details_hash|
        details_hash.merge!(PayloadBuilder::PoliticalDetails.for(item))
        details_hash.merge!(PayloadBuilder::FirstPublicAt.for(item))
        details_hash.merge!(PayloadBuilder::BodyHeadings.for(item))
      end
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
