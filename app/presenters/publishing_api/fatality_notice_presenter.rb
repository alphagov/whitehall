module PublishingApi
  class FatalityNoticePresenter
    include UpdateTypeHelper

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
          schema_name: "fatality_notice",
          details:,
          links: edition_links,
          auth_bypass_ids: [item.auth_bypass_id],
        )
        content.merge!(PayloadBuilder::AccessLimitation.for(item))
        content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
      end
    end

    def links
      # TODO: Previously, this presenter was sending all links to the
      # Publishing API at both the document level, and edition
      # level. This is probably redundant, and hopefully can be
      # improved.
      edition_links
    end

    def edition_links
      LinksPresenter.new(item).extract(
        %i[organisations],
      ).merge(
        field_of_operation: [item.operational_field.content_id],
      ).merge(
        PayloadBuilder::People.for(item),
      ).merge(
        PayloadBuilder::Roles.for(item),
      )
    end

    def document_type
      "fatality_notice"
    end

  private

    attr_reader :item

    def details
      details_hash = {
        body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item),
        casualties: item.fatality_notice_casualties.map(&:personal_details),
        change_history: item.change_history.as_json,
        emphasised_organisations: item.lead_organisations.map(&:content_id),
        roll_call_introduction: item.roll_call_introduction,
      }
      details_hash.merge!(PayloadBuilder::FirstPublicAt.for(item))
    end
  end
end
