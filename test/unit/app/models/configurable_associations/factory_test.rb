require "test_helper"

class ConfigurableAssociations::FactoryTest < ActiveSupport::TestCase
  test "configurable_associations raises an error if the association does not exist" do
    association_config = [
      {
        "key" => "invalid_association",
      },
    ]
    configurable_document_type = build_configurable_document_type("test_type", { "associations" => association_config })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = build(:draft_standard_edition)
    error = assert_raises do
      ConfigurableAssociations::Factory.new(edition).configurable_associations
    end
    assert_equal "Undefined association: invalid_association", error.message
  end

  test "configurable_associations builds all of the configured associations for an edition" do
    association_config = [
      {
        "key" => "ministerial_role_appointments",
      },
      {
        "key" => "topical_events",
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
    ]
    configurable_document_type = build_configurable_document_type("test_type", { "associations" => association_config })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = build(:draft_standard_edition, :with_organisations)
    factory = ConfigurableAssociations::Factory.new(edition)
    role_appointments = mock("ConfigurableAssociations::RoleAppointments")
    ConfigurableAssociations::MinisterialRoleAppointments.expects(:new).with(edition.role_appointments).returns(role_appointments)
    topical_events = mock("ConfigurableAssociations::TopicalEvents")
    ConfigurableAssociations::TopicalEvents.expects(:new).with(edition.topical_events).returns(topical_events)
    world_locations = mock("ConfigurableAssociations::WorldLocations")
    ConfigurableAssociations::WorldLocations.expects(:new).with(edition.world_locations, edition.errors).returns(world_locations)
    organisations = mock("ConfigurableAssociations::Organisations")
    ConfigurableAssociations::Organisations.expects(:new).with(edition.edition_organisations, edition.errors).returns(organisations)
    worldwide_organisations = mock("ConfigurableAssociations::WorldwideOrganisations")
    ConfigurableAssociations::WorldwideOrganisations.expects(:new).with(edition.worldwide_organisation_document_ids, edition.errors).returns(worldwide_organisations)

    assert_equal [role_appointments, topical_events, world_locations, organisations, worldwide_organisations], factory.configurable_associations
  end
end
