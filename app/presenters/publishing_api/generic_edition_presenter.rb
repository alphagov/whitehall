module PublishingApi
  class GenericEditionPresenter
    include UpdateTypeHelper

    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || default_update_type(item)
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItemPresenter.new(item).base_attributes
      content.merge!(
        description: item.summary,
        details: PayloadBuilder::TagDetails.for(item),
        document_type: item.display_type_key,
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: item.rendering_app,
        schema_name: "placeholder_#{item.class.name.underscore}",
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
  end
end
