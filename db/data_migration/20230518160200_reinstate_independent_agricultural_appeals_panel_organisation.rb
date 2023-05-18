def recreate_organisation_and_dependencies
  iaap_organisation = Organisation.create!(
    id: 210,
    slug: "independent-agricultural-appeals-panel",
    url: "",
    alternative_format_contact_email: "",
    govuk_status: "live",
    organisation_logo_type_id: 2,
    analytics_identifier: "PB210",
    handles_fatalities: false,
    important_board_members: 1,
    default_news_organisation_image_data_id: nil,
    closed_at: nil,
    organisation_brand_colour_id: 7,
    ocpa_regulated: nil,
    public_meetings: nil,
    public_minutes: nil,
    register_of_interests: nil,
    regulatory_function: nil,
    logo: nil,
    organisation_type_key: "advisory_ndpb",
    foi_exempt: false,
    organisation_chart_url: "",
    govuk_closed_status: nil,
    custom_jobs_url: "",
    content_id: "7a1b7347-6040-4b8c-9687-b18a0125b5e6",
    homepage_type: "news",
    political: false,
    ministerial_ordering: nil,
    name: "Independent Agricultural Appeals Panel",
    logo_formatted_name: "Independent Agricultural \r\nAppeals Panel",
    acronym: "IAAP",
  )

  recreate_contacts
  recreate_topical_event_organisation
  recreate_parent_organisations(iaap_organisation)
  recreate_editions(iaap_organisation)
end

def recreate_contacts
  Contact.create!(
    id: 1_958,
    latitude: nil,
    longitude: nil,
    contactable_id: 210,
    contactable_type: "Organisation",
    postal_code: "EX1 1QA",
    country_id: 202,
    contact_type_id: 1,
    content_id: "e78661f1-265d-4ef2-a358-0af9d7dbe667",
    title: "Independent Agricultural Appeals Panel",
    comments: "",
    recipient: "Appeals Team, Rural Payments Agency",
    street_address: "Sterling House, Dixs Field",
    locality: "Exeter",
    region: "",
    email: "reviewappealsteam1@rpa.gov.uk",
    contact_form_url: "",
  )

  Contact.create!(
    id: 1_959,
    latitude: nil,
    longitude: nil,
    contactable_id: 210,
    contactable_type: "Organisation",
    postal_code: "",
    country_id: nil,
    contact_type_id: 2,
    content_id: "ded458df-6a73-45a7-9867-b5623f788570",
    title: "FOI requests",
    comments: "",
    recipient: "",
    street_address: "",
    locality: "",
    region: "",
    email: "irt@rpa.gov.uk",
    contact_form_url: "",
  )
end

def recreate_topical_event_organisation
  TopicalEventOrganisation.create!(
    id: 592,
    organisation_id: 210,
    topical_event_id: 30,
    ordering: 0,
    lead: false,
    lead_ordering: nil,
  )
end

def recreate_parent_organisations(iaap_organisation)
  if Organisation.where(id: 7, acronym: "Defra").any?
    OrganisationalRelationship.create!(
      parent_organisation: Organisation.find(7),
      child_organisation: iaap_organisation,
    )
  end

  if Organisation.where(id: 58, acronym: "RPA").any?
    OrganisationalRelationship.create!(
      parent_organisation: Organisation.find(58),
      child_organisation: iaap_organisation,
    )
  end
end

def recreate_editions(iaap_organisation)
  if Edition.where(id: 335_894, summary: "The Independent Agricultural Appeals Panel (IAAP) advises ministers on the merits of decisions taken by the Rural Payments Agency in relation to payments under a wide range of schemes in the EU’s Common Agricultural Policy.").any?
    EditionOrganisation.create!(
      edition: Edition.find(335_894),
      organisation: iaap_organisation,
    )
  end

  if Edition.where(id: 355_464, summary: "The Independent Agricultural Appeals Panel (IAAP) considers appeals against decisions of the Rural Payments Agency, making recommendations on individual cases to the Parliamentary Under Secretary of State with responsibility for Farming.").any?
    EditionOrganisation.create!(
      edition: Edition.find(355_464),
      organisation: iaap_organisation,
    )
  end

  if Edition.where(id: 359_304, summary: "The Independent Agricultural Appeals Panel (IAAP) considers appeals against decisions of the Rural Payments Agency.").any?
    EditionOrganisation.create!(
      edition: Edition.find(359_304),
      organisation: iaap_organisation,
    )
  end

  if Edition.where(id: 427_964, summary: "The Independent Agricultural Appeals Panel (IAAP) considers appeals against decisions of the Rural Payments Agency.").any?
    EditionOrganisation.create!(
      edition: Edition.find(427_964),
      organisation: iaap_organisation,
    )
  end

  if Edition.where(id: 575_001, summary: "The Independent Agricultural Appeals Panel (IAAP) considers appeals against decisions of the Rural Payments Agency.").any?
    EditionOrganisation.create!(
      edition: Edition.find(575_001),
      organisation: iaap_organisation,
    )
  end

  # Deleted edition, restoring linkage for completeness
  if Edition.unscoped.where(id: 804_908, summary: "The Independent Agricultural Appeals Panel (IAAP) considers appeals against decisions of the Rural Payments Agency.").any?
    EditionOrganisation.create!(
      edition: Edition.unscoped.find(804_908),
      organisation: iaap_organisation,
    )
  end

  if Edition.where(id: 804_920, summary: "The Independent Agricultural Appeals Panel (IAAP) considers appeals against decisions of the Rural Payments Agency.").any?
    EditionOrganisation.create!(
      edition: Edition.find(804_920),
      organisation: iaap_organisation,
    )
  end

  if Edition.where(id: 1_157_167, summary: "The Independent Agricultural Appeals Panel (IAAP) considers appeals against decisions of the Rural Payments Agency.").any?
    EditionOrganisation.create!(
      edition: Edition.find(1_157_167),
      organisation: iaap_organisation,
    )
  end

  if Edition.where(id: 1_250_541, summary: "The Independent Agricultural Appeals Panel (IAAP) considers appeals against decisions of the Rural Payments Agency.").any?
    EditionOrganisation.create!(
      edition: Edition.find(1_250_541),
      organisation: iaap_organisation,
    )
  end

  if Edition.where(id: 1_307_046, summary: "The Independent Agricultural Appeals Panel (IAAP) considers appeals against decisions of the Rural Payments Agency.").any?
    EditionOrganisation.create!(
      edition: Edition.find(1_307_046),
      organisation: iaap_organisation,
    )
  end
end

recreate_organisation_and_dependencies unless Organisation.where(id: 210, slug: "independent-agricultural-appeals-panel").any?
