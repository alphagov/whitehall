require "test_helper"

class RoleAppointmentTest < ActiveSupport::TestCase

  test "should link a MinisterialRole to the Person who currently holds the role" do
    role = create(:ministerial_role)
    alice = create(:person, name: "Alice")
    bob = create(:person, name: "Bob")
    create(:role_appointment, role: role, person: alice, started_at: 3.days.ago, ended_at: 1.day.ago)
    create(:role_appointment, role: role, person: bob, started_at: 1.day.ago)

    assert_equal bob, role.current_person
  end

  test "should link the Person to the MinisterialRoles they currently hold" do
    alice = create(:person, name: "Alice")
    old_role = create(:ministerial_role)
    new_role = create(:ministerial_role)
    other_new_role = create(:ministerial_role)

    create(:role_appointment, role: old_role, person: alice, started_at: 3.days.ago, ended_at: 1.day.ago)
    create(:role_appointment, role: new_role, person: alice, started_at: 1.day.ago)
    create(:role_appointment, role: other_new_role, person: alice, started_at: 10.days.ago)

    assert_equal [new_role, other_new_role], alice.current_roles
  end

  test "should make appointments historical when a new Person is appointed to a MinisterialRole" do
    alice = create(:person, name: "Alice")
    bob = create(:person, name: "Bob")

    role = create(:ministerial_role)

    original_appointment = create(:role_appointment, role: role, person: alice, started_at: 3.days.ago)

    assert_equal alice, role.current_person, "the minister should be alice"
    assert_equal [role], alice.current_roles, "alice should be the minister"
    assert_equal [], bob.current_roles, "bob should have no roles"

    create(:role_appointment, role: role, person: bob, started_at: 1.day.ago)

    role.reload
    alice.reload
    bob.reload

    assert_equal [], alice.current_roles, "alice should no longer be the minister"
    assert_equal bob, role.current_person, "the minister should be bob"
    assert_equal [role], bob.current_roles, "bob should be the minister"
  end

end