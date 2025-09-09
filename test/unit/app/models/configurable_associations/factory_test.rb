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
    ]
    configurable_document_type = build_configurable_document_type("test_type", { "associations" => association_config })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = build(:draft_standard_edition)
    factory = ConfigurableAssociations::Factory.new(edition)
    role_appointments = mock("ConfigurableAssociations::RoleAppointments")
    ConfigurableAssociations::MinisterialRoleAppointments.expects(:new).with(edition.role_appointments).returns(role_appointments)
    topical_events = mock("ConfigurableAssociations::TopicalEvents")
    ConfigurableAssociations::TopicalEvents.expects(:new).with(edition.topical_events).returns(topical_events)

    assert_equal [role_appointments, topical_events], factory.configurable_associations
  end
end
