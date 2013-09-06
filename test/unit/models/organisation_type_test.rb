require 'test/unit'
require 'active_support'
require './app/models/organisation_type'

class OrganisationTypeTest < ActiveSupport::TestCase
  test "it should take key, name and analytics_prefix as initialize arguments and expose them as properties" do
    instance = OrganisationType.new(:some_type_key, "A Name", "A prefix")

    assert_equal :some_type_key, instance.key
    assert_equal "A Name",       instance.name
    assert_equal "A prefix",     instance.analytics_prefix
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
    assert_equal OrganisationType.get(:executive_office), OrganisationType.executive_office
    assert_equal OrganisationType.get(:ministerial_department), OrganisationType.ministerial_department
    assert_equal OrganisationType.get(:non_ministerial_department), OrganisationType.non_ministerial_department
    assert_equal OrganisationType.get(:executive_agency), OrganisationType.executive_agency
    assert_equal OrganisationType.get(:executive_ndpb), OrganisationType.executive_ndpb
    assert_equal OrganisationType.get(:advisory_ndpb), OrganisationType.advisory_ndpb
    assert_equal OrganisationType.get(:tribunal_ndpb), OrganisationType.tribunal_ndpb
    assert_equal OrganisationType.get(:public_corporation), OrganisationType.public_corporation
    assert_equal OrganisationType.get(:independent_monitoring_body), OrganisationType.independent_monitoring_body
    assert_equal OrganisationType.get(:adhoc_advisory_group), OrganisationType.adhoc_advisory_group
    assert_equal OrganisationType.get(:other), OrganisationType.other
    assert_equal OrganisationType.get(:sub_organisation), OrganisationType.sub_organisation
    assert_equal OrganisationType.get(:devolved_administration), OrganisationType.devolved_administration
  end

  test "OrganisationType should have boolean flags for each organisation type" do
    assert OrganisationType.get(:executive_office).executive_office?
    assert OrganisationType.get(:ministerial_department).ministerial_department?
    assert OrganisationType.get(:non_ministerial_department).non_ministerial_department?
    assert OrganisationType.get(:executive_agency).executive_agency?
    assert OrganisationType.get(:executive_ndpb).executive_ndpb?
    assert OrganisationType.get(:advisory_ndpb).advisory_ndpb?
    assert OrganisationType.get(:tribunal_ndpb).tribunal_ndpb?
    assert OrganisationType.get(:public_corporation).public_corporation?
    assert OrganisationType.get(:independent_monitoring_body).independent_monitoring_body?
    assert OrganisationType.get(:adhoc_advisory_group).adhoc_advisory_group?
    assert OrganisationType.get(:other).other?
    assert OrganisationType.get(:sub_organisation).sub_organisation?
    assert OrganisationType.get(:devolved_administration).devolved_administration?
  end

  test "is_non_departmental_public_body? should return true if key is :executive_ndpb, :advisory_ndpb or :tribunal_ndpb" do
    assert OrganisationType.new(:executive_ndpb, '', '').is_non_departmental_public_body?
    assert OrganisationType.new(:advisory_ndpb, '', '').is_non_departmental_public_body?
    assert OrganisationType.new(:tribunal_ndpb, '', '').is_non_departmental_public_body?
    refute OrganisationType.new(:executive_office, '', '').is_non_departmental_public_body?
  end

  test "agency_or_public_body? should return true if key is not :executive_office, :ministerial_department, :non_ministerial_department, :public_corporation or :sub_organisation" do
    refute OrganisationType.get(:executive_office).agency_or_public_body?
    refute OrganisationType.get(:ministerial_department).agency_or_public_body?
    refute OrganisationType.get(:non_ministerial_department).agency_or_public_body?
    assert OrganisationType.get(:executive_agency).agency_or_public_body?
    assert OrganisationType.get(:executive_ndpb).agency_or_public_body?
    assert OrganisationType.get(:advisory_ndpb).agency_or_public_body?
    assert OrganisationType.get(:tribunal_ndpb).agency_or_public_body?
    refute OrganisationType.get(:public_corporation).agency_or_public_body?
    assert OrganisationType.get(:independent_monitoring_body).agency_or_public_body?
    assert OrganisationType.get(:adhoc_advisory_group).agency_or_public_body?
    assert OrganisationType.get(:other).agency_or_public_body?
    refute OrganisationType.get(:sub_organisation).agency_or_public_body?
    refute OrganisationType.get(:devolved_administration).agency_or_public_body?
  end

  test "valid_keys should return all keys on DATA" do
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
      :other
    ], OrganisationType.valid_keys
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
      :other
    ], OrganisationType.in_listing_order.map(&:key)
  end

  test "listing_position should return the index of the type key in the listing order" do
    assert_equal 1, OrganisationType.get(:ministerial_department).listing_position
    assert_equal 5, OrganisationType.get(:advisory_ndpb).listing_position
  end
end