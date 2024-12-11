module PublishingApi
  class EditionableTopicalEventPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    attr_accessor :item, :update_type, :state

    def initialize(item, update_type: nil, state: "published")
      self.item = item
      self.update_type = update_type || "major"
      self.state = state
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.title,
        update_type:,
      ).base_attributes

      content.merge!(
        description: item.summary,
        details:,
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name: "topical_event",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      {}
    end

  private

    def details
      {}.tap do |details|
        details[:social_media_links] = social_media_links
      end
    end

    def social_media_links
      item.social_media_accounts.map do |social_media_account|
        {
          href: social_media_account.url,
          service_type: social_media_account.service_name.parameterize,
          title: social_media_account.display_name,
        }
      end
    end
  end
end
