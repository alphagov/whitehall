require "test_helper"

class ConfigurableAssociations::FactoryTest < ActiveSupport::TestCase
  test "it raises an error if the association does not exist" do
    edition = StandardEdition.new
    error = assert_raises do
      ConfigurableAssociations::Factory.new([], edition).build("missing")
    end
    assert_equal "Undefined association: missing", error.message
  end

  test "it raises an error if the config does not exist" do
    edition = StandardEdition.new
    error = assert_raises do
      ConfigurableAssociations::Factory.new([], edition).build("role_appointments")
    end
    assert_equal "config not found for association: role_appointments", error.message
  end

  test "it can build a role appointments association" do
    edition = StandardEdition.new
    config = [{
      "key" => "role_appointments",
      "label" => "Ministers",
    }]
    factory = ConfigurableAssociations::Factory.new(config, edition)
    association = mock("ConfigurableAssociations::RoleAppointment")
    ConfigurableAssociations::RoleAppointments.expects(:new).with(config.first, edition.role_appointments).returns(association)
    assert_equal association, factory.build("role_appointments")
  end

  test "it can build a topical events association" do
    edition = StandardEdition.new
    config = [{
      "key" => "topical_events",
      "label" => "Topical events",
    }]
    factory = ConfigurableAssociations::Factory.new(config, edition)
    association = mock("ConfigurableAssociations::TopicalEvents")
    ConfigurableAssociations::TopicalEvents.expects(:new).with(config.first, edition.topical_events).returns(association)
    assert_equal association, factory.build("topical_events")
  end
end
