module PublishingApi
  class EditionableWorldwideOrganisationPresenter
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
        update_type:,
      ).base_attributes

      content.merge!(
        details: {
          logo: {
            crest: "single-identity",
          },
        },
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "worldwide_organisation",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      {}
    end
  end
end
