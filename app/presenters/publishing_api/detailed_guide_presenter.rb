module PublishingApi
  class DetailedGuidePresenter
    include Presenters::PublishingApi::UpdateTypeHelper
    include GovspeakHelper

    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || default_update_type(item)
    end

    delegate :content_id, to: :item

    def content
      BaseItemPresenter
        .new(item, update_type:)
        .base_attributes
        .merge(PayloadBuilder::PublicDocumentPath.for(item))
        .merge(PayloadBuilder::AccessLimitation.for(item))
        .merge(PayloadBuilder::FirstPublishedAt.for(item))
        .merge(
          description: item.summary,
          details:,
          document_type:,
          public_updated_at: item.public_timestamp || item.updated_at,
          rendering_app: item.rendering_app,
          schema_name: "detailed_guide",
          links: edition_links,
          auth_bypass_ids: [item.auth_bypass_id],
        )
    end

    def links
      {}
    end

    def edition_links
      PayloadBuilder::Links.for(item).extract(
        %i[
          organisations
          government
        ],
      ).merge(
        related_guides: item.related_detailed_guide_content_ids,
        related_mainstream_content: related_mainstream_content_ids,
      ).merge(
        PayloadBuilder::TopicalEvents.for(item),
      )
    end

    def document_type
      "detailed_guide"
    end

  private

    def maybe_add_national_applicability(content)
      return content unless item.nation_inapplicabilities.any?

      content.merge(national_applicability: item.national_applicability)
    end

    def details
      details_hash = {
        body:,
        change_history: item.change_history.as_json,
        emphasised_organisations: item.lead_organisations.map(&:content_id),
        related_mainstream_content: related_mainstream_content_ids,
      }
      details_hash = maybe_add_national_applicability(details_hash)
      details_hash[:image] = { url: item.logo_url } if item.logo_url.present?
      details_hash.merge!(PayloadBuilder::PoliticalDetails.for(item))
      details_hash.merge!(PayloadBuilder::TagDetails.for(item))
      details_hash.merge!(PayloadBuilder::FirstPublicAt.for(item))
      details_hash.merge!(PayloadBuilder::Attachments.for(item))
      details_hash.merge!(PayloadBuilder::BodyHeadings.for(item))
    end

    def body
      govspeak_edition_to_html(item)
    end

    def related_mainstream_content_ids
      @related_mainstream_content_ids ||= item.related_mainstreams.pluck(:content_id)
    end
  end
end
