require 'test/unit'
require 'active_support'
require './app/models/organisation_type'

class OrganisationTypeTest < ActiveSupport::TestCase
  test "it should take key, name and analytics_prefix as initialize arguments and expose them as properties" do
    instance = OrganisationType.new(:some_type_key,
                                    name: "A Name",
                                    analytics_prefix: "A prefix",
                                    agency_or_public_body: true,
                                    non_departmental_public_body: false)

    assert_equal :some_type_key, instance.key
    assert_equal "A Name",       instance.name
    assert_equal "A prefix",     instance.analytics_prefix
    assert_equal true,           instance.agency_or_public_body?
    assert_equal false,          instance.non_departmental_public_body?
  end

  test "get should return an instance populated with the correct attributes" do
    assert_equal "Public corporation", OrganisationType.get(:public_corporation).name
    assert_equal "PC",                 OrganisationType.get(:public_corporation).analytics_prefix

    assert_equal "Sub-organisation",   OrganisationType.get(:sub_organisation).name
    assert_equal "OT",                 OrganisationType.get(:sub_organisation).analytics_prefix
  end

  test "get should accept keys as strings" do
    assert_equal "Public corporation", OrganisationType.get('public_corporation').name
  end

  test "get should throw a KeyError if bad key is given" do
    assert_raises(KeyError) {
      OrganisationType.get(:non_existant_org_type)
    }
  end

  test "get should return the same instance when called a second time with the same key" do
    instance_1 = OrganisationType.get(:executive_agency)
    instance_2 = OrganisationType.get(:executive_agency)

    assert_equal instance_1, instance_2
  end

  test "OrganisationType should have getters for each organisation type" do
    OrganisationType::DATA.keys.each do |key|
      assert_equal OrganisationType.get(key), OrganisationType.send(key)
    end
  end

  test "OrganisationType should have boolean flags for each organisation type" do
    OrganisationType::DATA.keys.each do |key|
      assert OrganisationType.get(key).send("#{key}?")
    end
  end

  test "valid_keys should return all keys on DATA" do
    assert_equal OrganisationType::DATA.keys, OrganisationType.valid_keys
  end

  test "in_listing_order should return all types in the appropriate order" do
    assert_equal [
      :executive_office,
      :ministerial_department,
      :non_ministerial_department,
      :executive_agency,
      :executive_ndpb,
      :advisory_ndpb,
      :tribunal_ndpb,
      :public_corporation,
      :independent_monitoring_body,
      :adhoc_advisory_group,
      :devolved_administration,
      :sub_organisation,
      :other,
      :civil_service,
    ], OrganisationType.in_listing_order.map(&:key)
  end

  test "listing_position should return the index of the type key in the listing order" do
    assert_equal 1, OrganisationType.get(:ministerial_department).listing_position
    assert_equal 5, OrganisationType.get(:advisory_ndpb).listing_position
  end
end
