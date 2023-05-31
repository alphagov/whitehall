module PublishingApi
  class WorldwideOrganisationPresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
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
        details: {
          body:,
          logo: {
            crest: "single-identity",
            formatted_title: item.logo_formatted_name,
          },
          ordered_corporate_information_pages:,
          social_media_links:,
        },
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "worldwide_organisation",
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {
        corporate_information_pages:,
        ordered_contacts:,
        primary_role_person:,
        secondary_role_person:,
        office_staff:,
        sponsoring_organisations:,
        world_locations:,
      }
    end

    def description
      item.summary
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_to_html(item.body) || ""
    end

    def ordered_contacts
      return [] unless item.offices.any?

      item.offices.map(&:contact).map(&:content_id)
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

    def corporate_information_pages
      return [] unless item.corporate_information_pages.any?

      item.corporate_information_pages.map(&:content_id)
    end

    def ordered_corporate_information_pages
      corporate_information_pages = item.corporate_information_pages&.published
      return [] unless corporate_information_pages

      links = []

      %i[our_information jobs_and_contracts].each do |page_type|
        corporate_information_pages.by_menu_heading(page_type).each do |corporate_information_page|
          links << {
            content_id: corporate_information_page.content_id,
            title: corporate_information_page.title,
          }
        end
      end

      publication_scheme = corporate_information_pages.find_by(corporate_information_page_type_id: CorporateInformationPageType::PublicationScheme.id)
      if publication_scheme.present?
        links << {
          content_id: publication_scheme.content_id,
          title: I18n.t("worldwide_organisation.corporate_information.publication_scheme_html", link: corporate_information_page_link_text("publication_scheme")),
        }
      end

      welsh_language_scheme = corporate_information_pages.find_by(corporate_information_page_type_id: CorporateInformationPageType::WelshLanguageScheme.id)
      if welsh_language_scheme.present?
        links << {
          content_id: welsh_language_scheme.content_id,
          title: I18n.t("worldwide_organisation.corporate_information.welsh_language_scheme_html", link: corporate_information_page_link_text("welsh_language_scheme")),
        }
      end

      personal_information_charter = corporate_information_pages.find_by(corporate_information_page_type_id: CorporateInformationPageType::PersonalInformationCharter.id)
      if personal_information_charter.present?
        links << {
          content_id: personal_information_charter.content_id,
          title: I18n.t("worldwide_organisation.corporate_information.personal_information_charter_html", link: corporate_information_page_link_text("personal_information_charter")),
        }
      end

      links
    end

    def corporate_information_page_link_text(key)
      I18n.t("corporate_information_page.type.link_text.#{key}", default: I18n.t("corporate_information_page.type.title.#{key}"))
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
  end
end
