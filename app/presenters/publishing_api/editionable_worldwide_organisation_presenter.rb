module PublishingApi
  class EditionableWorldwideOrganisationPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper
    include ApplicationHelper
    include OrganisationHelper

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
            formatted_title: worldwide_organisation_logo_name(item),
          },
          social_media_links:,
        },
        document_type: "worldwide_organisation",
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "worldwide_organisation",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      {
        roles: item.roles.map(&:content_id),
        sponsoring_organisations: item.organisations.map(&:content_id),
        world_locations: item.world_locations.map(&:content_id),
      }
    end

  private

    def social_media_links
      return [] unless item.social_media_accounts.any?

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
