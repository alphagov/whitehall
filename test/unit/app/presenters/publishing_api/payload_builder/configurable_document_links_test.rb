require "test_helper"

class PublishingApi::PayloadBuilder::ConfigurableDocumentLinksTest < ActiveSupport::TestCase
  setup do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type("test_type", {
        "presenters" => {
          "publishing_api" => {
            "links" => %w[
              ministerial_role_appointments
              topical_events
              world_locations
              organisations
              worldwide_organisations
              government
            ],
          },
        },
      }).merge(
        build_configurable_document_type("topical_event"),
      ),
    )
  end

  test "includes the selected content IDs for government links" do
    government = create(:government)
    edition = create(:standard_edition, government_id: government.id)

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    assert_equal [government.content_id], links[:government]
  end

  test "it presents the selected organisations, emphasised organisations and primary publishing organisation links" do
    organisations = create_list(:organisation, 3)
    edition = create(:draft_standard_edition)
    edition.edition_organisations.create([{ organisation: organisations.first, lead: true, lead_ordering: 0 }, { organisation: organisations.last, lead: false }])

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_links = {
      organisations: [organisations.first.content_id, organisations.last.content_id],
      emphasised_organisations: [organisations.first.content_id],
      primary_publishing_organisation: [organisations.first.content_id],
    }
    assert_equal expected_links, links.slice(*expected_links.keys)
  end

  test "it presents the first lead organisation as the primary publishing organisation" do
    organisations = create_list(:organisation, 3)
    edition = create(:draft_standard_edition)
    edition.edition_organisations.create([{ organisation: organisations.first, lead: true, lead_ordering: 1 }, { organisation: organisations.last, lead: true, lead_ordering: 0 }])

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    assert_equal [organisations.last.content_id], links[:primary_publishing_organisation]
  end

  test "it sends no primary publishing organisation if there are no lead organisations" do
    organisations = create_list(:organisation, 2)
    edition = create(:draft_standard_edition)
    edition.edition_organisations.create([{ organisation: organisations.first, lead: false }, { organisation: organisations.last, lead: false }])

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    assert_equal [], links[:primary_publishing_organisation]
  end

  test "it sorts the organisaton links by lead order with supporting organisations last" do
    organisations = create_list(:organisation, 4)
    edition = create(:draft_standard_edition)
    edition.edition_organisations.create([
      { organisation: organisations.first, lead: false },
      { organisation: organisations.second, lead: true, lead_ordering: 1 },
      { organisation: organisations.last, lead: true, lead_ordering: 0 },
      { organisation: organisations.third, lead: false },
    ])

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_order = [
      organisations.last.content_id,
      organisations.second.content_id,
      organisations.first.content_id,
      organisations.third.content_id,
    ]
    assert_equal expected_order, links[:organisations]
  end

  test "it sorts the emphasised organisation links by lead order" do
    organisations = create_list(:organisation, 2)
    edition = create(:draft_standard_edition)
    edition.edition_organisations.create([
      { organisation: organisations.first, lead: true, lead_ordering: 1 },
      { organisation: organisations.last, lead: true, lead_ordering: 0 },
    ])

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_order = [
      organisations.last.content_id,
      organisations.first.content_id,
    ]
    assert_equal expected_order, links[:emphasised_organisations]
  end

  test "it presents the selected world location links" do
    world_locations = create_list(:world_location, 3, active: true)
    edition = create(:draft_standard_edition, { world_locations: [world_locations.first, world_locations.last] })

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_links = [world_locations.first.content_id, world_locations.last.content_id]
    assert_equal expected_links, links[:world_locations]
  end

  test "it presents the selected worldwide organisations" do
    worldwide_organisations = create_list(:worldwide_organisation, 2)
    edition = create(:draft_standard_edition)
    edition.edition_worldwide_organisations.create([{ document: worldwide_organisations.first.document }, { document: worldwide_organisations.last.document }])

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_links = worldwide_organisations.map(&:content_id)

    assert_equal expected_links, links[:worldwide_organisations]
  end

  test "it presents the selected topical event links" do
    topical_events = create_list(:topical_event, 3)
    topical_event_documents = create_list(:standard_edition, 3, configurable_document_type: "topical_event")
    edition = create(:draft_standard_edition, {
      topical_events: [topical_events.first, topical_events.last],
      topical_event_documents: [topical_event_documents.first.document, topical_event_documents.last.document],
    })

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_links = [
      topical_events.first.content_id,
      topical_events.last.content_id,
      topical_event_documents.first.document.content_id,
      topical_event_documents.last.document.content_id,
    ]
    assert_equal expected_links, links[:topical_events]
  end

  test "it presents the selected role appointment links" do
    appointments = create_list(:ministerial_role_appointment, 3)
    edition = create(:draft_standard_edition)
    edition.role_appointments << [appointments.first, appointments.last]
    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_links = {
      people: [appointments.first.person.content_id, appointments.last.person.content_id],
      roles: [appointments.first.role.content_id, appointments.last.role.content_id],
    }
    assert_equal expected_links, links.slice(*expected_links.keys)
  end

  test "it avoids sending duplicate people in the links when more than one role appointment is held by the same person" do
    person = create(:person)
    role1 = create(:ministerial_role)
    role2 = create(:ministerial_role)
    appointment1 = create(:ministerial_role_appointment, person: person, role: role1)
    appointment2 = create(:ministerial_role_appointment, person: person, role: role2)

    edition = create(:draft_standard_edition)
    edition.role_appointments << [appointment1, appointment2]
    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_links = {
      people: [person.content_id],
      roles: [role1.content_id, role2.content_id],
    }
    assert_equal expected_links, links.slice(*expected_links.keys)
  end

  test "it avoids sending duplicate role IDs in case there is more than one appointment for the same role" do
    person = create(:person)
    role = create(:ministerial_role)
    appointment1 = create(:ministerial_role_appointment, person: person, role: role)
    appointment2 = build(:ministerial_role_appointment, person: person, role: role)
    appointment2.content_id = SecureRandom.uuid # for the presenter to work
    appointment2.save!(validate: false) # bypass 'overlap' validation

    edition = create(:draft_standard_edition)
    edition.role_appointments << [appointment1, appointment2]
    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_links = {
      people: [person.content_id],
      roles: [role.content_id],
    }
    assert_equal expected_links, links.slice(*expected_links.keys)
  end
end
