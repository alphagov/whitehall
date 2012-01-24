require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    person = build(:person)
    assert person.valid?
  end

  test "should be invalid without a name" do
    person = build(:person, title: nil, forename: nil, surname: nil, letters: nil)
    refute person.valid?
  end

  test '#ministerial_roles includes all ministerial roles' do
    minister = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, role: minister, person: person)
    assert_equal [minister], person.current_ministerial_roles
  end

  test '#ministerial_roles excludes non-ministerial roles' do
    permanent_secretary = create(:board_member_role)
    person = create(:person)
    create(:role_appointment, role: permanent_secretary, person: person)
    assert_equal [], person.current_ministerial_roles
  end

  test '#board_member_roles includes all non-ministerial roles' do
    permanent_secretary = create(:board_member_role)
    person = create(:person)
    create(:role_appointment, role: permanent_secretary, person: person)
    assert_equal [permanent_secretary], person.current_board_member_roles
  end

  test '#board_member_roles excludes any ministerial roles' do
    role_appointment = create(:ministerial_role_appointment)
    person = create(:person, role_appointments: [role_appointment])
    assert_equal [], person.current_board_member_roles
  end

  test "should not be destroyable when it has appointments" do
    person = create(:person, role_appointments: [create(:role_appointment)])
    refute person.destroyable?
    assert_equal false, person.destroy
  end

  test "should be destroyable when it has no appointments" do
    person = create(:person, role_appointments: [])
    assert person.destroyable?
    assert person.destroy
  end
end