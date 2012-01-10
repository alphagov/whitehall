require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    organisation = build(:organisation)
    assert organisation.valid?
  end

  test 'should be invalid without a name' do
    organisation = build(:organisation, name: nil)
    refute organisation.valid?
  end

  test 'should be invalid with a duplicate name' do
    existing_organisation = create(:organisation)
    new_organisation = build(:organisation, name: existing_organisation.name)
    refute new_organisation.valid?
  end

  test "should be orderable ignoring common prefixes" do
    culture = create(:organisation, name: "Department for Culture and Sports")
    education = create(:organisation, name: "Department of Education")
    hmrc = create(:organisation, name: "HMRC")
    defence = create(:organisation, name: "Ministry of Defence")

    assert_equal [culture, defence, education, hmrc], Organisation.ordered_by_name_ignoring_prefix
  end

  test "#child_organisations should return the parent's children organisations" do
    parent_org_1 = create(:organisation)
    parent_org_2 = create(:organisation)
    child_org_1 = create(:organisation, parent_organisations: [parent_org_1])
    child_org_2 = create(:organisation, parent_organisations: [parent_org_1])
    child_org_3 = create(:organisation, parent_organisations: [parent_org_2])

    assert_equal [child_org_1, child_org_2], parent_org_1.child_organisations
  end
  
  test "#parent_organisations should return the child's parent organisations" do
    child_org_1 = create(:organisation)
    child_org_2 = create(:organisation)
    parent_org_1 = create(:organisation, child_organisations: [child_org_1])
    parent_org_2 = create(:organisation, child_organisations: [child_org_1])
    parent_org_3 = create(:organisation, child_organisations: [child_org_2])

    assert_equal [parent_org_1, parent_org_2], child_org_1.parent_organisations
  end

  test '#ministerial_roles includes all ministerial roles' do
    minister = create(:ministerial_role)
    organisation = create(:organisation, roles:  [minister])
    assert_equal [minister], organisation.ministerial_roles
  end

  test '#ministerial_roles excludes non-ministerial roles' do
    permanent_secretary = create(:board_member_role)
    organisation = create(:organisation, roles:  [permanent_secretary])
    assert_equal [], organisation.ministerial_roles
  end

  test '#board_member_roles includes all non-ministerial roles' do
    permanent_secretary = create(:board_member_role)
    organisation = create(:organisation, roles:  [permanent_secretary])
    assert_equal [permanent_secretary], organisation.board_member_roles
  end

  test '#board_member_roles excludes any ministerial roles' do
    minister = create(:ministerial_role)
    organisation = create(:organisation, roles:  [minister])
    assert_equal [], organisation.board_member_roles
  end

  test 'should be creatable with contact data' do
    params = {
      email: "someone@gov.uk", address: "Aviation House, London",
      postcode: "WC2A 1BE", latitude: -0.112311, longitude: 51.215125,
      phone_numbers_attributes: [
        {description: "Helpline", number: "020712345678"},
        {description: "Fax", number: "020712345679"}
      ]
    }
    organisation = create(:organisation, params)

    assert_equal "someone@gov.uk", organisation.email
    assert_equal "Aviation House, London", organisation.address
    assert_equal "WC2A 1BE", organisation.postcode
    assert_equal -0.112311, organisation.latitude
    assert_equal 51.215125, organisation.longitude
    assert_equal 2, organisation.phone_numbers.count
    assert_equal "Helpline", organisation.phone_numbers[0].description
    assert_equal "020712345678", organisation.phone_numbers[0].number
    assert_equal "Fax", organisation.phone_numbers[1].description
    assert_equal "020712345679", organisation.phone_numbers[1].number
  end

  test "should set a slug from the organisation name" do
    organisation = create(:organisation, name: 'Love all the people')
    assert_equal 'love-all-the-people', organisation.slug
  end

  test "should not change the slug when the name is changed" do
    organisation = create(:organisation, name: 'Love all the people')
    organisation.update_attributes(name: 'Hold hands')
    assert_equal 'love-all-the-people', organisation.slug
  end

  test "should concatenate words containing apostrophes" do
    organisation = create(:organisation, name: "Bob's bike")
    assert_equal 'bobs-bike', organisation.slug
  end
end