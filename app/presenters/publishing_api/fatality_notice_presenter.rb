module PublishingApi
  class FatalityNoticePresenter
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
      {}.tap { |content|
        content.merge!(BaseItemPresenter.new(item).base_attributes)
        content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
        content.merge!(
          description: item.summary,
          document_type: "fatality_notice",
          public_updated_at: item.public_timestamp || item.updated_at,
          rendering_app: item.rendering_app,
          schema_name: "fatality_notice",
          details: details
        )
        content.merge!(PayloadBuilder::AccessLimitation.for(item))
      }
    end

    def links
      LinksPresenter.new(item).extract(
        %i(organisations policy_areas)
      ).merge(
        field_of_operation: [item.operational_field.content_id]
      )
    end

  private

    attr_reader :item

    def details
      {
        body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item),
        first_public_at: first_public_at,
        change_history: item.change_history.as_json,
        emphasised_organisations: item.lead_organisations.map(&:content_id)
      }
    end

    def first_public_at
      document = item.document
      document.published? ? item.first_public_at : document.created_at
    end
  end
end
