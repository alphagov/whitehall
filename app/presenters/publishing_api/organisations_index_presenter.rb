module PublishingApi
  class OrganisationsIndexPresenter
    def content_id
      "fde62e52-dfb6-42ae-b336-2c4faf068101"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "Departments, agencies and public bodies",
        update_type: "minor",
        locale: :en, # Note: the organisations index page is only available in english
      ).base_attributes

      content.merge!(
        base_path:,
        description: "Information from government departments, agencies and public bodies, including news, campaigns, policies and contact details.",
        document_type: "finder",
        public_updated_at: Time.zone.now.iso8601,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name: "organisations_homepage",
        details: organisations_list,
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def base_path
      "/government/organisations"
    end

    def links
      {}
    end

    def organisations_list
      {
        ordered_executive_offices: organisation_details_by_type(:executive_office),
        ordered_ministerial_departments: organisation_details_by_type(:ministerial_department),
        ordered_non_ministerial_departments: organisation_details_by_type(:non_ministerial_department),
        ordered_agencies_and_other_public_bodies: organisation_details_by_type(:agencies_and_government_bodies),
        ordered_high_profile_groups: organisation_details_by_type(:high_profile_group),
        ordered_public_corporations: organisation_details_by_type(:public_corporation),
        ordered_devolved_administrations: organisation_details_by_type(:devolved_administration),
      }
    end

    def organisation_details(organisation)
      {
        title: organisation.name,
        href: organisation.public_path,
        brand: organisation.organisation_brand,
        logo: organisation_logo(organisation),
        separate_website: organisation.exempt?,
        format: organisation.type.name,
        updated_at: organisation.updated_at,
        slug: organisation.slug,
        acronym: organisation.acronym,
        closed_at: organisation.closed_at,
        govuk_status: organisation.govuk_status,
        govuk_closed_status: organisation.govuk_closed_status,
        content_id: organisation.content_id,
        analytics_identifier: organisation.analytics_identifier,
        parent_organisations: parent_organisations(organisation),
        child_organisations: child_organisations(organisation),
        superseded_organisations: superseded_organisations(organisation),
        superseding_organisations: superseding_organisations(organisation),
        works_with: organisation_works_with(organisation),
      }
    end

    def organisation_logo(organisation)
      case organisation.organisation_crest
      when "no-identity"
        {
          formatted_title: organisation.logo_formatted_name,
        }
      when "custom"
        {
          formatted_title: organisation.logo_formatted_name,
          image: {
            url: organisation.logo_url,
            alt_text: organisation.name,
          },
        }
      else
        {
          formatted_title: organisation.logo_formatted_name,
          crest: organisation.organisation_crest,
        }
      end
    end

    def parent_organisations(organisation)
      organisation.parent_organisations.map { |o| summary_organisation(o) }
    end

    def child_organisations(organisation)
      organisation.child_organisations.map { |o| summary_organisation(o) }
    end

    def superseded_organisations(organisation)
      organisation.superseded_organisations.map { |o| summary_organisation(o) }
    end

    def superseding_organisations(organisation)
      organisation.superseding_organisations.map { |o| summary_organisation(o) }
    end

    def organisation_works_with(organisation)
      organisation.supporting_bodies_grouped_by_type.each_with_object({}) do |group, groups|
        groups[group[0].key] = group[1].map { |o| summary_organisation(o) }
      end
    end

    def summary_organisation(organisation)
      {
        title: organisation.name,
        href: organisation.public_path,
      }
    end

    def organisation_details_by_type(type)
      grouped_organisations.fetch(type, []).map { |org| organisation_details(org) }
    end

    def grouped_organisations
      @grouped_organisations ||= presented_organisations.group_by do |org|
        if org.type.agency_or_public_body?
          :agencies_and_government_bodies
        elsif org.type.sub_organisation?
          :high_profile_group
        else
          org.type.key
        end
      end
    end

    def presented_organisations
      @presented_organisations ||= Organisation.excluding_courts_and_tribunals.listable.ordered_by_name_ignoring_prefix
    end
  end
end
