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
          ordered_corporate_information_pages:,
          secondary_corporate_information_pages:,
          social_media_links:,
          world_location_names:,
        },
        document_type: "worldwide_organisation",
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "worldwide_organisation",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {
        corporate_information_pages:,
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

  private

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
    end

    def corporate_information_pages
      return [] unless item.corporate_information_pages.any?

      item.corporate_information_pages.map(&:content_id)
    end

    def ordered_corporate_information_pages
      corporate_information_pages = item.corporate_information_pages&.published
      return [] if corporate_information_pages.empty?

      links = []

      %i[our_information jobs_and_contracts].each do |page_type|
        corporate_information_pages.by_menu_heading(page_type).each do |corporate_information_page|
          links << {
            content_id: corporate_information_page.content_id,
            title: corporate_information_page.title,
          }
        end
      end

      links
    end

    def secondary_corporate_information_pages
      corporate_information_pages = item.corporate_information_pages&.published
      return [] unless corporate_information_pages

      sentences = []

      publication_scheme = corporate_information_pages.find_by(corporate_information_page_type_id: CorporateInformationPageType::PublicationScheme.id)
      if publication_scheme.present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.publication_scheme_html",
          link: t_corporate_information_page_link(item, "publication-scheme"),
        )
      end

      welsh_language_scheme = corporate_information_pages.find_by(corporate_information_page_type_id: CorporateInformationPageType::WelshLanguageScheme.id)
      if welsh_language_scheme.present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.welsh_language_scheme_html",
          link: t_corporate_information_page_link(item, "welsh-language-scheme"),
        )
      end

      personal_information_charter = corporate_information_pages.find_by(corporate_information_page_type_id: CorporateInformationPageType::PersonalInformationCharter.id)
      if personal_information_charter.present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.personal_information_charter_html",
          link: t_corporate_information_page_link(item, "personal-information-charter"),
        )
      end

      sentences.join(" ")
    end

    def t_corporate_information_page_type_link_text(page)
      if I18n.exists?("corporate_information_page.type.link_text.#{page.display_type_key}")
        I18n.t("corporate_information_page.type.link_text.#{page.display_type_key}")
      else
        I18n.t("corporate_information_page.type.title.#{page.display_type_key}")
      end
    end

    def t_corporate_information_page_link(organisation, slug)
      page = organisation.corporate_information_pages.published.for_slug(slug)
      page.extend(UseSlugAsParam)
      link_to(
        t_corporate_information_page_type_link_text(page),
        page.public_path,
        class: "govuk-link",
      )
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
