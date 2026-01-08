require "test_helper"

class PublishingApi::PayloadBuilder::ConfigurableDocumentLinksTest < ActiveSupport::TestCase
  test "includes the selected content IDs for each configured association" do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type("test_type", {
        "associations" => [
          {
            "key" => "ministerial_role_appointments",
          },
          {
            "key" => "topical_events",
          },
          {
            "key" => "topical_event_documents",
          },
          {
            "key" => "world_locations",
          },
          {
            "key" => "organisations",
          },
          {
            "key" => "worldwide_organisations",
          },
        ],
      }).merge(
        build_configurable_document_type("topical_event"),
      ),
    )
    ministerial_role_appointments = create_list(:ministerial_role_appointment, 2)
    topical_events = create_list(:topical_event, 2)
    topical_event_documents = create_list(:published_standard_edition, 2, configurable_document_type: "topical_event").map(&:document)
    world_locations = create_list(:world_location, 2, active: true)
    organisations = create_list(:organisation, 2)
    edition = build(:standard_edition,
                    role_appointments: ministerial_role_appointments,
                    topical_events:,
                    topical_event_documents:,
                    world_locations:)
    edition.edition_organisations.build([{ organisation: organisations.first, lead: true, lead_ordering: 0 }, { organisation: organisations.last, lead: false }])
    worldwide_organisations = create_list(:worldwide_organisation, 2)
    edition.edition_worldwide_organisations.build([{ document: worldwide_organisations.first.document }, { document: worldwide_organisations.last.document }])

    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_people, expected_roles = ministerial_role_appointments
                                        .map { |appointment| [appointment.person.content_id, appointment.role.content_id] }
                                        .transpose
    assert_equal expected_people, links[:people]
    assert_equal expected_roles, links[:roles]
    expected_topical_events = topical_events.map(&:content_id) + topical_event_documents.map(&:content_id)
    assert_equal expected_topical_events, links[:topical_events]
    expected_world_locations = world_locations.map(&:content_id)
    assert_equal expected_world_locations, links[:world_locations]
    expected_organisations = organisations.map(&:content_id)
    assert_equal expected_organisations, links[:organisations]
    expected_primary_publishing_organisation = [organisations.first.content_id]
    assert_equal expected_primary_publishing_organisation, links[:primary_publishing_organisation]
    expected_worldwide_organisations = worldwide_organisations.map(&:content_id)
    assert_equal expected_worldwide_organisations, links[:worldwide_organisations]
  end

  test "includes government link if the document type has it configured" do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type("test_type", {
        "settings" => {
          "history_mode_enabled" => true,
        },
      }),
    )
    government = create(:government)
    edition = build(:standard_edition, government_id: government.id)
    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    expected_government = [edition.government.content_id]
    assert_equal expected_government, links[:government]
  end

  test "includes empty government link if the document type has it configured but no government has been set" do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type("test_type", {
        "settings" => {
          "history_mode_enabled" => true,
        },
      }),
    )
    edition = build(:standard_edition)
    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    assert_equal [], links[:government]
  end

  test "does not include government link if the document type does not have it configured" do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type("test_type", {
        "settings" => {
          "history_mode_enabled" => false,
        },
      }),
    )
    government = create(:government)
    edition = build(:standard_edition, government_id: government.id)
    links = PublishingApi::PayloadBuilder::ConfigurableDocumentLinks.for(edition)
    assert_nil links[:government]
  end
end
