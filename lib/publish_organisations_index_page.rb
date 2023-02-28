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
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        routes: [
          {
            path: BASE_PATH,
            type: "exact",
          },
        ],
        public_updated_at: Time.zone.now.iso8601,
        update_type: "minor",
      },
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
      ordered_devolved_administrations: organisation_details(:devolved_administrations),
    }
  end

  def organisation_details(organisation_type_key)
    presented_organisations.send(organisation_type_key).map do |organisation|
      {
        title: organisation.name,
        href: organisation.public_path(locale: I18n.default_locale),
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
      href: organisation.public_path(locale: I18n.default_locale),
    }
  end

  def presented_organisations
    @presented_organisations ||= OrganisationsIndexPresenter.new(all_organisations)
  end

  def all_organisations
    @all_organisations ||= Organisation.excluding_courts_and_tribunals.listable.ordered_by_name_ignoring_prefix
  end
end
