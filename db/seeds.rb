# The test environment expects an empty test database. These seeds are used
# to set up the minimum for a dev environment and are used with
# https://github.com/alphagov/publishing-e2e-tests
return if Rails.env.test?

if User.where(name: "Test user").blank?
  gds_organisation_id = "af07d5a5-df63-4ddc-9383-6a666845ebe9"
  User.create!(
    name: "Test user",
    permissions: ["signin", "GDS Admin", "GDS Editor", "Managing Editor", "Export data"],
    organisation_content_id: gds_organisation_id,
    organisation_slug: "government-digital-service",
  )
end

if Organisation.where(name: "HM Revenue & Customs").blank?
  Organisation.skip_callback(:commit, :after, :publish_to_publishing_api)
  Organisation.skip_callback(:save, :after, :republish_how_government_works_page_to_publishing_api)
  Organisation.create!(
    name: "HM Revenue & Customs",
    slug: "hm-revenue-customs",
    acronym: "HMRC",
    organisation_type_key: :other,
    logo_formatted_name: "Test",
    content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
  )
end

if Organisation.where(name: "Test Organisation").blank?
  Organisation.create!(
    name: "Test Organisation",
    slug: "government-digital-service",
    acronym: "TO",
    organisation_type_key: :other,
    logo_formatted_name: "Test",
  )
end

if Government.where(name: "Test Government").blank?
  Government.skip_callback(:commit, :after, :publish_to_publishing_api)
  Government.create!(
    name: "Test Government",
    start_date: Time.zone.local(2001, 1, 1),
  )
end

WorldLocationNews.skip_callback(:commit, :after, :publish_to_publishing_api)

if WorldLocation.where(name: "Test World Location").blank?
  world_location = WorldLocation.create!(
    name: "Test World Location",
    world_location_type: "world_location",
  )

  world_location_news = WorldLocationNews.create!(
    world_location:,
    mission_statement: "Our mission is to test world locations",
    title: "UK and Test World Location",
  )

  FeaturedLink.create!(
    url: "https://www.gov.uk",
    title: "GOV.UK Homepage",
    linkable: world_location_news,
  )
end

if WorldLocation.where(name: "Test International Delegation").blank?
  international_delegation = WorldLocation.create!(
    name: "Test International Delegation",
    world_location_type: "international_delegation",
  )

  international_delegation_news = WorldLocationNews.create!(
    world_location: international_delegation,
    mission_statement: "Our mission is to test international delegations",
    title: "UK at Test International Delegation",
  )

  FeaturedLink.create!(
    url: "https://www.gov.uk",
    title: "GOV.UK Homepage",
    linkable: international_delegation_news,
  )

  if Role.where(slug: "prime-minister").blank?
    Role.skip_callback(:commit, :after, :publish_to_publishing_api)
    Person.skip_callback(:commit, :after, :publish_to_publishing_api)
    RoleAppointment.skip_callback(:commit, :after, :publish_to_publishing_api)
    RoleAppointment.skip_callback(:save, :after, :republish_prime_ministers_index_page_to_publishing_api)
    RoleAppointment.skip_callback(:save, :after, :republish_how_government_works_page_to_publishing_api)
    HistoricalAccount.skip_callback(:commit, :after, :publish_to_publishing_api)
    HistoricalAccount.skip_callback(:save, :after, :republish_prime_ministers_index_page_to_publishing_api)

    prime_minister_role = Role.create!(
      name: "Prime Minister",
      slug: "prime-minister",
      type: "MinisterialRole",
      permanent_secretary: false,
      cabinet_member: true,
      chief_of_the_defence_staff: false,
      supports_historical_accounts: true,
    )

    previous_prime_minister = Person.create!(
      forename: "Previous",
      surname: "Prime Minister",
      slug: "previous-prime-minister",
    )

    RoleAppointment.create!(
      role: prime_minister_role,
      person: previous_prime_minister,
      started_at: 2.years.ago,
      ended_at: 1.year.ago,
    )

    HistoricalAccount.create!(
      person: previous_prime_minister,
      summary: "This person served as the previous Prime Minister",
      body: "Some information about their work.",
      political_party_ids: [1],
      roles: [prime_minister_role],
    )

    current_prime_minister = Person.create!(
      forename: "Current",
      surname: "Prime Minister",
      slug: "current-prime-minister",
    )

    RoleAppointment.create!(
      role: prime_minister_role,
      person: current_prime_minister,
      started_at: 1.year.ago,
      ended_at: nil,
    )
  end
end
