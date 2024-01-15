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
        description: item.summary,
        details: {
          body:,
          logo: {
            crest: "single-identity",
            formatted_title: worldwide_organisation_logo_name(item),
          },
          social_media_links:,
          world_location_names:,
        },
        document_type:,
        links: edition_links,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "worldwide_organisation",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def edition_links
      {
        office_staff:,
        main_office:,
        home_page_offices:,
        primary_role_person:,
        roles: item.roles.map(&:content_id),
        secondary_role_person:,
        sponsoring_organisations: item.organisations.map(&:content_id),
        world_locations: item.world_locations.map(&:content_id),
      }
    end

    def document_type
      "worldwide_organisation"
    end

    def links
      {
        home_page_offices: [],
        main_office: [],
        office_staff: [],
        primary_role_person: [],
        roles: [],
        secondary_role_person: [],
        sponsoring_organisations: [],
        world_locations: [],
      }
    end

  private

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
    end

    def office_staff
      item.office_staff_roles.map(&:current_person).map(&:content_id)
    end

    def main_office
      return [] unless item.main_office

      [item.main_office.content_id]
    end

    def home_page_offices
      return [] unless item.home_page_offices.any?

      item.home_page_offices.map(&:content_id)
    end

    def primary_role_person
      return [] unless item.primary_role

      [item.primary_role.current_person.content_id]
    end

    def secondary_role_person
      return [] unless item.secondary_role

      [item.secondary_role.current_person.content_id]
    end

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

    def world_location_names
      return [] unless item.world_locations.any?

      item.world_locations.map do |world_location|
        {
          content_id: world_location.content_id,
          name: world_location.name,
        }
      end
    end
  end
end
