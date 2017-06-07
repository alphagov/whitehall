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
    assert_nil build(:organisation, organisation_type_key: nil).organisation_type
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

  test "listable should return all organisations which are not 'closed'" do
    ministerial_department = create(:ministerial_department)
    sub_organisation = create(:sub_organisation)
    closed_org = create(:closed_organisation)
    assert Organisation.listable.include?(ministerial_department)
    assert Organisation.listable.include?(sub_organisation)
    refute Organisation.listable.include?(closed_org)
  end

  test "allowed_promotional should return all organisatiosn which are allowed_promotional" do
    promotional_org = create(:organisation, organisation_type_key: :civil_service)
    non_promotional_org = create(:sub_organisation)

    assert Organisation.allowed_promotional.include?(promotional_org)
    refute Organisation.allowed_promotional.include?(non_promotional_org)
  end

  class HMCTSOrganisationTests < ActiveSupport::TestCase
    def setup
      @other_org = create(:organisation)
      @copyright_tribunal = create(:organisation, organisation_type_key: :tribunal_ndpb,
        name: "Copyright Tribunal", parent_organisations: [@other_org])
      @multiple_parent_child_org = create(:organisation, parent_organisations: [@other_org, @copyright_tribunal])
      @court = create(:court)
      @hmcts_tribunal = create(:hmcts_tribunal)
      @closed_hmcts_tribunal = create(:hmcts_tribunal, :closed)
    end

    test "hmcts_tribunals selects Tribunals that are administrered by HMCTS" do
      result = Organisation.closed.hmcts_tribunals
      refute_includes result, @other_org
      refute_includes result, @copyright_tribunal
      refute_includes result, @court
      assert_includes result, @closed_hmcts_tribunal
      refute_includes result, @hmcts_tribunal
    end

    test "excluding_hmcts_tribunals excludes Tribunals that are administrered by HMCTS" do
      result = Organisation.excluding_hmcts_tribunals.listable
      assert_includes result, @other_org
      assert_includes result, @copyright_tribunal
      assert_includes result, @court
      refute_includes result, @hmcts_tribunal
    end

    test "excluding_courts_and_tribunals scopes to exclude courts and HMCTS tribunals" do
      result = Organisation.excluding_courts_and_tribunals.listable
      assert_includes result, @other_org
      assert_includes result, @copyright_tribunal
      refute_includes result, @court
      refute_includes result, @hmcts_tribunal
    end

    test "excluding_courts scopes to exclude courts tribunals" do
      result = Organisation.excluding_courts.listable
      assert_includes result, @other_org
      assert_includes result, @copyright_tribunal
      refute_includes result, @court
      assert_includes result, @hmcts_tribunal
    end

    test "excluding_hmcts_tribunals deduplicates organisations" do
      result = Organisation.excluding_hmcts_tribunals.listable.map(&:id)
      assert_equal result, result.uniq
    end
  end

  test "supporting_bodies should exclude closed orgs, sub orgs, and courts and tribunals and be in alphabetical order" do
    parent_org_1 = create(:organisation)
    parent_org_2 = create(:organisation)
    child_org_1 = create(:organisation, parent_organisations: [parent_org_1], name: "b second")
    child_org_2 = create(:sub_organisation, parent_organisations: [parent_org_1])
    child_org_3 = create(:organisation, parent_organisations: [parent_org_1], name: "a first")
    child_org_4 = create(:closed_organisation, parent_organisations: [parent_org_1])
    child_org_5 = create(:court, parent_organisations: [parent_org_1])
    child_org_6 = create(:organisation, parent_organisations: [parent_org_1], name: "c third", organisation_type_key: :tribunal_ndpb)

    assert_equal [child_org_3, child_org_1, child_org_6], parent_org_1.supporting_bodies
  end

  test "supporting_bodies_grouped_by_type should return a 2D array with each 1st level member being a OrganisationType and a collection of organisations" do
    parent_org = create(:organisation)
    child_org_1 = create(:organisation, parent_organisations: [parent_org], organisation_type_key: :executive_agency)
    child_org_2 = create(:sub_organisation, parent_organisations: [parent_org], organisation_type_key: :advisory_ndpb)

    assert_equal [
      [OrganisationType.executive_agency, [child_org_1]],
      [OrganisationType.advisory_ndpb,    [child_org_2]]
    ], parent_org.supporting_bodies_grouped_by_type
  end

  test 'can list its sub-organisations' do
    parent = create(:organisation)
    sub_organisation = create(:sub_organisation, parent_organisations: [parent])
    assert_equal [sub_organisation], parent.sub_organisations
  end

  test "should index Organisations" do
    organisation = create(:organisation)
    assert organisation.can_index_in_search?
  end

  test "should index Courts" do
    court = create(:court)
    assert court.can_index_in_search?
  end

  test "should publish Organisations to Publishing API" do
    organisation = create(:organisation)
    assert organisation.can_publish_to_publishing_api?
  end

  test "should publish Courts to Publishing API" do
    court = create(:court)
    assert court.can_publish_to_publishing_api?
  end

  test "#hmcts_tribunal? should be true if it's an HMCTS tribunal only" do
    hmcts_tribunal = create(:hmcts_tribunal)
    tribunal = create(:organisation, organisation_type_key: :tribunal_ndpb)
    hmcts_child = create(:organisation,
      parent_organisations: [Organisation.find_by(slug: "hm-courts-and-tribunals-service")])

    assert hmcts_tribunal.hmcts_tribunal?
    refute tribunal.hmcts_tribunal?
    refute hmcts_child.hmcts_tribunal?
  end
end
