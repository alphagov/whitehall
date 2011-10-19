require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    person = build(:person)
    assert person.valid?
  end

  test "should be invalid without a name" do
    person = build(:person, name: nil)
    refute person.valid?
  end

  test '#ministerial_roles includes all ministerial roles' do
    minister = create(:ministerial_role)
    person = create(:person, roles:  [minister])
    assert_equal [minister], person.ministerial_roles
  end

  test '#ministerial_roles excludes non-ministerial roles' do
    permanent_secretary = create(:board_member_role)
    person = create(:person, roles:  [permanent_secretary])
    assert_equal [], person.ministerial_roles
  end

  test '#board_member_roles includes all non-ministerial roles' do
    permanent_secretary = create(:board_member_role)
    person = create(:person, roles:  [permanent_secretary])
    assert_equal [permanent_secretary], person.board_member_roles
  end

  test '#board_member_roles excludes any ministerial roles' do
    minister = create(:ministerial_role)
    person = create(:person, roles:  [minister])
    assert_equal [], person.board_member_roles
  end
end