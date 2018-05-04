class PublishOrganisationsIndexPage
  def publish
    payload = present_for_publishing_api
    Services.publishing_api.put_content(payload[:content_id], payload[:content])
    Services.publishing_api.publish(payload[:content_id], nil, locale: "en")
  end

private

  BASE_PATH = "/government/organisations".freeze
  CONTENT_ID = "fde62e52-dfb6-42ae-b336-2c4faf068101".freeze

  def present_for_publishing_api
    {
      content_id: CONTENT_ID,
      content: {
        details: organisations_list,
        title: "Departments, agencies and public bodies",
        description: "Information from government departments, agencies and public bodies, including news, campaigns, policies and contact details.",
        document_type: "finder",
        schema_name: "organisations_homepage",
        locale: "en",
        base_path: BASE_PATH,
        publishing_app: "whitehall",
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        routes: [
          {
            path: BASE_PATH,
            type: "exact",
          },
        ],
        public_updated_at: Time.zone.now.iso8601,
        update_type: "minor",
      }
    }
  end

  def organisations_list
    {
      ordered_executive_offices: organisation_details(:executive_offices),
      ordered_ministerial_departments: organisation_details(:ministerial_departments),
      ordered_non_ministerial_departments: organisation_details(:non_ministerial_departments),
      ordered_agencies_and_other_public_bodies: organisation_details(:agencies_and_government_bodies),
      ordered_high_profile_groups: organisation_details(:high_profile_groups),
      ordered_public_corporations: organisation_details(:public_corporations),
      ordered_devolved_administrations: organisation_details(:devolved_administrations)
    }
  end

  def organisation_details(organisation_type_key)
    presented_organisations.send(organisation_type_key).map do |organisation|
      {
        title: organisation.name,
        href: Whitehall.url_maker.polymorphic_path(organisation),
        brand: organisation.organisation_brand,
        logo: organisation_logo(organisation),
        separate_website: organisation.exempt?,
        works_with: organisation_works_with(organisation),
      }
    end
  end

  def organisation_logo(organisation)
    if organisation.organisation_crest == "no-identity"
      {
        formatted_title: organisation.logo_formatted_name
      }
    elsif organisation.organisation_crest == "custom"
      {
        formatted_title: organisation.logo_formatted_name,
        image: {
          url: organisation.logo_url,
          alt_text: organisation.name
        }
      }
    else
      {
        formatted_title: organisation.logo_formatted_name,
        crest: organisation.organisation_crest
      }
    end
  end

  def organisation_works_with(organisation)
    organisation.supporting_bodies_grouped_by_type.inject({}) do |groups, group|
      groups[group[0].key] = group[1].map do |o|
        {
          title: o.name,
          href: Whitehall.url_maker.polymorphic_path(o)
        }
      end

      groups
    end
  end

  def presented_organisations
    @presented_organisations ||= OrganisationsIndexPresenter.new(all_organisations)
  end

  def all_organisations
    @all_organisations ||= Organisation.excluding_courts_and_tribunals.listable.ordered_by_name_ignoring_prefix
  end
end
