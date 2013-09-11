require 'test_helper'

class OrganisationTypeConcernTest < ActiveSupport::TestCase

  ### Describing organisation type getters and setters ###
  test "should ensure that organisation_type_key is always returned as a symbol" do
    assert_equal :executive_office, build(:organisation, organisation_type_key: 'executive_office').organisation_type_key
  end

  test "should implement organisation_type, which returns an instance of the OrganisationType indicated by organisation_type_key" do
    assert_equal OrganisationType.ministerial_department, build(:organisation, organisation_type_key: :ministerial_department).organisation_type
  end

  test "organisation_type should not fall over if organisation doesn't have an organisation_type_key" do
    assert_equal nil, build(:organisation, organisation_type_key: nil).organisation_type
  end

  test "should implement organisation_type= which sets organisation_type_key to the OrganisationTyps's key." do
    organisation = build(:organisation)
    organisation.organisation_type = OrganisationType.independent_monitoring_body
    assert_equal :independent_monitoring_body, organisation.organisation_type_key
  end


  ### Describing Validations ###
  test "should validate that organisation_type_key is both present and of a valid type" do
    assert_valid build(:organisation, organisation_type_key: :executive_office)
    assert_invalid build(:organisation, organisation_type_key: :not_a_valid_key)
    assert_invalid build(:organisation, organisation_type_key: nil)
  end

  test "should validate that if an organisation is a sub_organisation then it has a parent organisation" do
    assert_invalid build(:organisation, organisation_type_key: :sub_organisation, parent_organisations: [])
    assert_valid build(:organisation, organisation_type_key: :sub_organisation, parent_organisations: [build(:organisation)])
    assert_valid build(:organisation, organisation_type_key: :executive_office, parent_organisations: [])
  end

  test 'sub-organisations are not valid without a parent organisation' do
    sub_organisation = build(:sub_organisation, parent_organisations: [])
    assert_invalid sub_organisation
    assert sub_organisation.errors.full_messages.include?("Parent organisations must not be empty for sub-organisations")
  end

  test "should validate that an organisation is govuk_status exempt if it's a devolved administration" do
    assert_invalid build(:sub_organisation, organisation_type: OrganisationType.devolved_administration, govuk_status: 'live')
    assert_valid build(:sub_organisation, organisation_type: OrganisationType.devolved_administration, govuk_status: 'exempt')
  end


  ### Describing Scopes ###
  test "It should have a scope for each valid OrganisationType" do
    OrganisationType.valid_keys.each do |key|
      if key == :sub_organisation
        org = create(:sub_organisation)
      elsif key == :devolved_administration
        org = create(:organisation, organisation_type_key: key, govuk_status: 'exempt')
      else
        org = create(:organisation, organisation_type_key: key)
      end
      assert_equal [org], Organisation.send(key.to_s.pluralize)
      Organisation.destroy_all
    end
  end

  test "listable should return all organisations which are not sub organisations" do
    top_level_org = create(:organisation, organisation_type_key: :executive_office)
    sub_org = create(:sub_organisation)

    assert Organisation.listable.include?(top_level_org)
    refute Organisation.listable.include?(sub_org)
  end

  test "listable should also exclude organisations which have govuk_status of 'closed'" do
    closed_org = create(:organisation, govuk_status: 'closed')
    refute Organisation.listable.include?(closed_org)
  end

  test "child_organisations_excluding_sub_organisations should live up to it's name" do
    parent_org_1 = create(:organisation)
    parent_org_2 = create(:organisation)
    child_org_1 = create(:organisation, parent_organisations: [parent_org_1])
    child_org_2 = create(:sub_organisation, parent_organisations: [parent_org_1])
    child_org_3 = create(:organisation, parent_organisations: [parent_org_1])

    assert_equal [child_org_1, child_org_3], parent_org_1.child_organisations_excluding_sub_organisations
  end

  test "child_organisations_excluding_sub_organisations_grouped_by_type should return a 2D array with each 1st level member being a OrganisationType and a collection of organisations" do
    parent_org = create(:organisation)
    child_org_1 = create(:organisation, parent_organisations: [parent_org], organisation_type_key: :executive_agency)
    child_org_2 = create(:sub_organisation, parent_organisations: [parent_org], organisation_type_key: :advisory_ndpb)

    assert_equal [
      [OrganisationType.executive_agency, [child_org_1]],
      [OrganisationType.advisory_ndpb,    [child_org_2]]
    ], parent_org.child_organisations_excluding_sub_organisations_grouped_by_type
  end

  test 'can list its sub-organisations' do
    parent = create(:organisation)
    sub_organisation = create(:sub_organisation, parent_organisations: [parent])
    assert_equal [sub_organisation], parent.sub_organisations
  end
end
