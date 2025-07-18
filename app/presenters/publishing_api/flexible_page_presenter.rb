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

      if type.settings["legacy_presenter"]
        # override the presented content - the frontend isn't ready yet
        stubbed = NewsArticle.new(
          document: item.document,
          title: item.title,
          body: "TESTING",
          summary: "TESTING",
          public_timestamp: content[:public_updated_at],
          news_article_type_id: Object.const_get("NewsArticleType::#{type.settings['publishing_api_document_type'].camelize}").id,
          auth_bypass_id: item.auth_bypass_id,
        )
        klass = Object.const_get("PublishingApi::#{type.settings["legacy_presenter"]}").new(stubbed)
        klass.content
        puts klass.content
      end
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
