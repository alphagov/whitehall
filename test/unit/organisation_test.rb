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
end