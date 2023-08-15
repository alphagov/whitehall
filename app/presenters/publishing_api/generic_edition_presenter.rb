module PublishingApi
  class GenericEditionPresenter
    include UpdateTypeHelper

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
        details: PayloadBuilder::TagDetails.for(item),
        document_type:,
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "placeholder_#{item.class.name.underscore}",
        auth_bypass_ids: [item.auth_bypass_id],
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PayloadBuilder::AccessLimitation.for(item))
    end

    def links
      LinksPresenter.new(item).extract([
        :organisations,
        :topics,
        :parent, # please use the breadcrumb component when migrating document_type to government-frontend
      ])
    end

    def document_type
      item.display_type_key
    end
  end
end
