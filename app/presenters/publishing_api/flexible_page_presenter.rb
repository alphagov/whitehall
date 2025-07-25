module PublishingApi
  class FlexiblePagePresenter
    include Presenters::PublishingApi::UpdateTypeHelper

    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || default_update_type(item)
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(item, update_type:).base_attributes
      content.merge!(
        details: {
          **FlexiblePageContentBlocks::DefaultObject.new.publishing_api_payload(type.schema, item.flexible_page_content),
        },
        document_type: type.settings["publishing_api_document_type"],
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: type.settings["rendering_app"],
        schema_name: type.settings["publishing_api_schema_name"],
        links: edition_links,
        auth_bypass_ids: [item.auth_bypass_id],
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def links
      {}
    end

    def edition_links
      {}
    end

  private

    def type
      item.type_instance
    end
  end
end
