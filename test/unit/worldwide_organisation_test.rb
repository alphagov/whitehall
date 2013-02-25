require 'test_helper'

class WorldwideOrganisationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :summary, :description

  test "should set a slug from the field name" do
    worldwide_organisation = create(:worldwide_organisation, name: 'Office Name')
    assert_equal 'office-name', worldwide_organisation.slug
  end

  %w{name summary description}.each do |param|
    test "should not be valid without a #{param}" do
      refute build(:worldwide_organisation, param.to_sym => '').valid?
    end
  end

  test 'can be associated with multiple world locations' do
    countries = [
      create(:country, name: 'France'),
      create(:country, name: 'Spain')
    ]
    worldwide_organisation = create(:worldwide_organisation, name: 'Office Name', world_locations: countries)

    assert_equal countries.sort_by(&:name), worldwide_organisation.world_locations.sort_by(&:name)
  end

  test "can be associated with one or more sponsoring organisations" do
    organisation = create(:organisation)
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_organisation.sponsoring_organisations << organisation

    assert_equal [organisation], worldwide_organisation.reload.sponsoring_organisations
  end

  test "destroys associated sponsorships" do
    worldwide_organisation = create(:worldwide_organisation, sponsoring_organisations: [create(:organisation)])
    worldwide_organisation.destroy
    assert_equal 0, worldwide_organisation.sponsorships.count
  end

  test "destroys associated role appointments" do
    worldwide_organisation = create(:worldwide_organisation, worldwide_organisation_roles: [create(:worldwide_organisation_role)])
    worldwide_organisation.destroy
    assert_equal 0, worldwide_organisation.worldwide_organisation_roles.count
  end

  test "has an overridable default main office" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.main_office

    office1 = create(:worldwide_office)
    worldwide_organisation.offices << office1
    assert_equal office1, worldwide_organisation.main_office

    office2 = create(:worldwide_office)
    worldwide_organisation.offices << office2
    assert_equal office1, worldwide_organisation.main_office

    worldwide_organisation.main_office = office2
    assert_equal office2, worldwide_organisation.main_office
  end

  test "distinguishes between the main office and other offices" do
    offices = [build(:worldwide_office), build(:worldwide_office)]
    worldwide_organisation = build(:worldwide_organisation, offices: offices, main_office: offices.last)

    assert worldwide_organisation.is_main_office?(offices.last)
    refute worldwide_organisation.is_main_office?(offices.first)
  end

  test "can list other offices" do
    offices = [build(:worldwide_office), build(:worldwide_office)]

    assert_equal [], build(:worldwide_organisation, offices: []).other_offices
    assert_equal [], build(:worldwide_organisation, offices: offices.take(1)).other_offices
    assert_equal [offices.last], build(:worldwide_organisation, offices: offices, main_office: offices.first).other_offices
  end

  test "an ambassadorial role is a primary role and not a secondary one" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    ambassador_role = create(:ambassador_role, worldwide_organisations: [worldwide_organisation])

    assert_equal ambassador_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a high commissioner role is a primary role and not a secondary one" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    high_commissioner_role = create(:high_commissioner_role, worldwide_organisations: [worldwide_organisation])

    assert_equal high_commissioner_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a governor role is a primary role and not a secondary one" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    governor_role = create(:governor_role, worldwide_organisations: [worldwide_organisation])

    assert_equal governor_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a deputy head of mission is second in charge and not a primary one" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_nil worldwide_organisation.secondary_role

    deputy_role = create(:deputy_head_of_mission_role, worldwide_organisations: [worldwide_organisation])

    assert_equal deputy_role, worldwide_organisation.secondary_role
    assert_nil worldwide_organisation.primary_role
  end

  test "office_staff_roles returns worldwide office staff roles" do
    worldwide_organisation = create(:worldwide_organisation)

    assert_equal [], worldwide_organisation.office_staff_roles

    staff_role1 = create(:worldwide_office_staff_role, worldwide_organisations: [worldwide_organisation])
    staff_role2 = create(:worldwide_office_staff_role, worldwide_organisations: [worldwide_organisation])

    assert_equal [staff_role1, staff_role2], worldwide_organisation.office_staff_roles
    assert_nil worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "has removeable translations" do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr, :es])
    worldwide_organisation.remove_translations_for(:fr)
    refute worldwide_organisation.translated_locales.include?(:fr)
    assert worldwide_organisation.translated_locales.include?(:es)
  end
end
