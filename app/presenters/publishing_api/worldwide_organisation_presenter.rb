module PublishingApi
  class WorldwideOrganisationPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper
    include ApplicationHelper
    include OrganisationHelper
    include Presenters::PublishingApi::DefaultNewsImageHelper

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
        title: item.name,
        update_type:,
      ).base_attributes

      content.merge!(
        description:,
        details:,
        document_type: item.class.name.underscore,
        links: edition_links,
        public_updated_at:,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "worldwide_organisation",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def edition_links
      {
        contacts:,
        corporate_information_pages: corporate_information_pages.map(&:content_id).sort,
        main_office:,
        home_page_offices:,
        primary_role_person:,
        roles:,
        role_appointments:,
        secondary_role_person:,
        office_staff:,
        sponsoring_organisations:,
        world_locations:,
      }
    end

    def links
      {}
    end

    def description
      return if about_us.blank?

      about_us.summary
    end

    def body
      if about_us&.body.present?
        Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(about_us)
      else
        ""
      end
    end

    def public_updated_at
      if state == "published"
        item.updated_at
      else
        ([item.updated_at, about_us&.updated_at] + corporate_information_pages.map(&:updated_at)).compact.max
      end
    end

    def about_us
      if state == "published"
        item.about_us
      else
        about_us_cips = item.corporate_information_pages.where(corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id)

        if about_us_cips.where(state:).any?
          about_us_cips.find_by(state:)
        else
          about_us_cips.find_by(state: "published")
        end
      end
    end

    def contacts
      return [] unless item.main_office_contact || item.home_page_office_contacts&.any?

      [item.main_office_contact&.content_id] + item.home_page_office_contacts&.map(&:content_id)
    end

    def main_office
      return [] unless item.main_office

      [item.main_office.content_id]
    end

    def home_page_offices
      return [] unless item.home_page_offices.any?

      item.home_page_offices.map(&:content_id)
    end

    def office_contact_associations
      offices = [item.main_office] + item.home_page_offices

      offices.compact.map do |office|
        {
          office_content_id: office.content_id,
          contact_content_id: office.contact.content_id,
        }
      end
    end

    def primary_role_person
      return [] unless item.primary_role

      [item.primary_role.current_person.content_id]
    end

    def secondary_role_person
      return [] unless item.secondary_role

      [item.secondary_role.current_person.content_id]
    end

    def office_staff
      item.office_staff_roles.map(&:current_person).map(&:content_id)
    end

    def role_appointments
      item.roles&.distinct&.map(&:current_role_appointment)&.compact&.map(&:content_id)
    end

    def roles
      item.roles.distinct.pluck(:content_id)
    end

    def people_role_associations
      people = [item.primary_role&.current_person] + [item.secondary_role&.current_person] + item.office_staff_roles.map(&:current_person)
      people.compact.map do |person|
        {
          person_content_id: person.content_id,
          role_appointments: person.current_role_appointments&.map do |role_appointment|
            {
              role_appointment_content_id: role_appointment.content_id,
              role_content_id: role_appointment.role.content_id,
            }
          end,
        }
      end
    end

    def corporate_information_pages
      return [] unless item.corporate_information_pages.any?

      if state == "published"
        item.corporate_information_pages.published.where.not(corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id)
      else
        cips_to_include = []

        all_cips = item.corporate_information_pages.where(state: ["published", state]).where.not(corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id)

        all_cips.pluck(:corporate_information_page_type_id).each do |corporate_information_page_type_id|
          cips_to_include << if all_cips.where(corporate_information_page_type_id:, state:).any?
                               all_cips.find_by(corporate_information_page_type_id:, state:).id
                             else
                               all_cips.find_by(corporate_information_page_type_id:, state: "published").id
                             end
        end

        item.corporate_information_pages.where(id: cips_to_include)
      end
    end

    def ordered_corporate_information_pages
      return [] unless corporate_information_pages.any?

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
      return "" unless corporate_information_pages.any?

      sentences = []

      publication_scheme = corporate_information_pages.find_by(corporate_information_page_type_id: CorporateInformationPageType::PublicationScheme.id)
      if publication_scheme.present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.publication_scheme_html",
          link: t_corporate_information_page_link("publication-scheme"),
        )
      end

      welsh_language_scheme = corporate_information_pages.find_by(corporate_information_page_type_id: CorporateInformationPageType::WelshLanguageScheme.id)
      if welsh_language_scheme.present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.welsh_language_scheme_html",
          link: t_corporate_information_page_link("welsh-language-scheme"),
        )
      end

      personal_information_charter = corporate_information_pages.find_by(corporate_information_page_type_id: CorporateInformationPageType::PersonalInformationCharter.id)
      if personal_information_charter.present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.personal_information_charter_html",
          link: t_corporate_information_page_link("personal-information-charter"),
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

    def t_corporate_information_page_link(slug)
      page = corporate_information_pages.for_slug(slug)
      page.extend(UseSlugAsParam)
      link_to(
        t_corporate_information_page_type_link_text(page),
        page.public_path,
        class: "govuk-link",
      )
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

    def sponsoring_organisations
      return [] unless item.sponsoring_organisations.any?

      item.sponsoring_organisations.map(&:content_id)
    end

    def world_locations
      return [] unless item.world_locations.any?

      item.world_locations.map(&:content_id)
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

  private

    def details
      details = {
        body:,
        logo: {
          crest: "single-identity",
          formatted_title: worldwide_organisation_logo_name(item),
        },
        office_contact_associations:,
        ordered_corporate_information_pages:,
        people_role_associations:,
        secondary_corporate_information_pages:,
        social_media_links:,
        world_location_names:,
      }
      details[:default_news_image] = present_default_news_image(item) if present_default_news_image(item).present?
      details
    end
  end
end
