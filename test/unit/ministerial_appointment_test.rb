require "test_helper"

class MinisterialAppointmentTest < ActiveSupport::TestCase

  test "should link a MinisterialRole to the Person who currently holds the role" do
    ministerial_role = create(:ministerial_role)
    alice = create(:person, name: "Alice")
    bob = create(:person, name: "Bob")
    create(:ministerial_appointment, ministerial_role: ministerial_role, person: alice, started_at: 3.days.ago, ended_at: 1.day.ago)
    create(:ministerial_appointment, ministerial_role: ministerial_role, person: bob, started_at: 1.day.ago)

    assert_equal bob, ministerial_role.person
  end

  test "should link the Person to the MinisterialRoles they currently hold" do
    alice = create(:person, name: "Alice")
    old_role = create(:ministerial_role)
    new_role = create(:ministerial_role)
    other_new_role = create(:ministerial_role)

    create(:ministerial_appointment, ministerial_role: old_role, person: alice, started_at: 3.days.ago, ended_at: 1.day.ago)
    create(:ministerial_appointment, ministerial_role: new_role, person: alice, started_at: 1.day.ago)
    create(:ministerial_appointment, ministerial_role: other_new_role, person: alice, started_at: 10.days.ago)

    assert_equal [new_role, other_new_role], alice.ministerial_roles
  end

  test "should make appointments historical when a new Person is appointed to a MinisterialRole" do
    alice = create(:person, name: "Alice")
    bob = create(:person, name: "Bob")

    ministerial_role = create(:ministerial_role)

    original_appointment = create(:ministerial_appointment, ministerial_role: ministerial_role, person: alice, started_at: 3.days.ago)

    assert_equal alice, ministerial_role.person, "the minister should be alice"
    assert_equal [ministerial_role], alice.ministerial_roles, "alice should be the minister"
    assert_equal [], bob.ministerial_roles, "bob should have no roles"

    create(:ministerial_appointment, ministerial_role: ministerial_role, person: bob, started_at: 1.day.ago)

    ministerial_role.reload
    alice.reload
    bob.reload

    assert_equal [], alice.ministerial_roles, "alice should no longer be the minister"
    assert_equal bob, ministerial_role.person, "the minister should be bob"
    assert_equal [ministerial_role], bob.ministerial_roles, "bob should be the minister"
  end

end