module PublishingApi
  class StandardEditionPresenter
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
        description: item.summary,
        details:,
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

    def details
      root_block = ConfigurableContentBlocks::Factory.new(item).build("object")
      {
        **flatten_headers(root_block.publishing_api_payload(type.schema, item.block_content)),
      }
    end

    def flatten_headers(content)
      headers = []

      content.keys.each do |key|
        content_for_key = content[key]

        next unless content_for_key.is_a?(Hash)

        html_for_content_block = content_for_key[:html]
        headers_for_content_block = content_for_key[:headers]
        content[key] = html_for_content_block if html_for_content_block.present?
        headers << headers_for_content_block if headers_for_content_block.present?
      end

      content[:headers] = headers.any? ? headers.flatten : nil
      content.compact
    end

    def type
      item.type_instance
    end
  end
end
