module PublishingApi
  class WorldwideOrganisationPresenter
    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.name,
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: description,
        details: {},
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "placeholder",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {}
    end

    def description
      item.summary
    end

    def social_media_links
      item.social_media_accounts.where(locale: I18n.locale).map do |account|
        {
          service_type: account.service_name.parameterize,
          title: account.display_name,
          href: account.url,
        }
      end
    end
  end
end
