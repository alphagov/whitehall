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
        details:,
        document_type:,
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: item.rendering_app,
        schema_name: "flexible_page",
        links: edition_links,
        auth_bypass_ids: [item.auth_bypass_id],
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
    end

    def links
      edition_links
    end

    def edition_links
      []
    end

    def document_type
      item.flexible_page_type
    end

  private

    def details
      {
        flexible_page_content:,
      }
    end

    def flexible_page_content
      flexible_page_type = FlexiblePageType.find(item.flexible_page_type)
      {
        rows: flexible_page_type.layout["rows"].map do |row|
          {
            columns: row["columns"].map do |column|
              {
                width: column["width"],
                blocks: column["blocks"].map do |block|
                  {
                    type: flexible_page_type.properties[block["schema_property_key"]]["type"],
                    value: item.flexible_page_content[block["schema_property_key"]]
                  }
                end
              }
            end
          }
        end
      }
    end
  end
end
