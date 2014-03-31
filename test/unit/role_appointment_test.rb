require "test_helper"

class RoleAppointmentTest < ActiveSupport::TestCase

  test "should should remove person from index when added as a minister" do
    person = create(:person)
    Whitehall::SearchIndex.expects(:delete).with(person)
    create(:ministerial_role_appointment, person: person)
  end

  test "should should add person to index when removed as a minister" do
    Whitehall::SearchIndex.stubs(:add)
    person = create(:person)
    role = create(:ministerial_role_appointment, person: person)
    Whitehall::SearchIndex.expects(:add).with(person)
    role.destroy
  end

  test "should add the person to the index when a they no longer hold a ministerial role" do
    Whitehall::SearchIndex.stubs(:add)

    role = create(:ministerial_role)
    alice = create(:person, forename: "Alice")
    bob = create(:person, forename: "Bob")

    create(:role_appointment, role: role, person: alice, started_at: 3.days.ago, ended_at: nil)

    Whitehall::SearchIndex.expects(:add).with(alice)

    role.reload
    alice.reload
    bob.reload

    create(:role_appointment, role: role, person: bob, started_at: 1.day.ago, ended_at: nil, make_current: true)

    assert_equal bob, role.current_person
    assert_equal alice.current_ministerial_roles.any?, false
  end

  test "should be invalid with no started_at" do
    role_appointment = build(:role_appointment, started_at: nil)
    refute role_appointment.valid?
  end

  test "should be invalid with no role" do
    role_appointment = build(:role_appointment, role: nil)
    refute role_appointment.valid?
  end

  test "should be invalid with no person" do
    role_appointment = build(:role_appointment, person: nil)
    refute role_appointment.valid?
  end

  test "should be invalid if ended_at is before started_at" do
    role_appointment = build(:role_appointment,
      started_at: Time.zone.parse("2000-12-30"),
      ended_at: Time.zone.parse("1999-01-01")
    )
    refute role_appointment.valid?
  end

  test "should be invalid if started_at is in the future" do
    role_appointment = build(:role_appointment, started_at: 1.second.from_now)
    refute role_appointment.valid?
  end

  test "should be invalid if ended_at is in the future" do
    role_appointment = build(:role_appointment, ended_at: 1.second.from_now)
    refute role_appointment.valid?
  end

  test "should not be current if not started" do
    role_appointment = build(:role_appointment, started_at: nil, ended_at: nil)
    refute role_appointment.current?
  end

  test "should be current if started but not ended" do
    role_appointment = build(:role_appointment, started_at: 2.years.ago, ended_at: nil)
    assert role_appointment.current?
  end

  test "should not be current if started and ended" do
    role_appointment = build(:role_appointment, started_at: 2.years.ago, ended_at: 1.year.ago)
    refute role_appointment.current?
  end

  test "should link a MinisterialRole to the Person who currently holds the role" do
    role = create(:ministerial_role)
    alice = create(:person, forename: "Alice")
    bob = create(:person, forename: "Bob")
    create(:role_appointment, role: role, person: alice, started_at: 3.days.ago, ended_at: 1.day.ago)
    create(:role_appointment, role: role, person: bob, started_at: 1.day.ago, ended_at: nil, make_current: true)

    assert_equal bob, role.current_person
  end

  test "should link the Person to the MinisterialRoles they currently hold" do
    alice = create(:person, forename: "Alice")
    old_role = create(:ministerial_role)
    new_role = create(:ministerial_role)
    other_new_role = create(:ministerial_role)

    create(:role_appointment, role: old_role, person: alice, started_at: 3.days.ago, ended_at: 1.day.ago)
    create(:role_appointment, role: new_role, person: alice, started_at: 1.day.ago, ended_at: nil, make_current: true)
    create(:role_appointment, role: other_new_role, person: alice, started_at: 10.days.ago, ended_at: nil, make_current: true)

    assert_equal [new_role, other_new_role], alice.current_roles
  end

  test "should be possible to create historical appointments without affecting the current one" do
    alice = create(:person, forename: "Alice")
    bob = create(:person, forename: "Bob")

    role = create(:ministerial_role)

    original_appointment = create(:role_appointment, role: role, person: alice, started_at: 3.days.ago)

    assert_equal alice, role.current_person, "the minister should be alice"
    assert_equal [role], alice.current_roles, "alice should be the minister"
    assert_equal [], bob.current_roles, "bob should have no roles"

    create(:role_appointment, role: role, person: bob, started_at: 10.day.ago, ended_at: 5.days.ago)

    role.reload
    alice.reload
    bob.reload

    assert_equal [role], alice.current_roles, "alice should still have the minister role"
    assert_equal alice, role.current_person, "the current minister should still be alice"
    assert_equal [], bob.current_roles, "bob should not have any roles"
  end

  test "should prevent creation of overlapping appointments" do
    role = create(:role)
    create(:role_appointment, role: role, started_at: 10.days.ago, ended_at: 5.days.ago)
    appointment = build(:role_appointment, role: role, started_at: 10.days.ago, ended_at: 3.days.ago)
    refute appointment.valid?
  end

  test "should not be considered to overlap with itself" do
    appointment = create(:role_appointment, started_at: 10.days.ago, ended_at: 5.days.ago)
    refute appointment.reload.overlaps_any?
  end

  # TEST FIXTURES FOR #overlaps_any? tests
  # ======================================
  #
  # '*'s have no significance other than a way of visually indicating when an example
  # starts, ends or includes the start or end date of the existing appointment.
  # Examples indicate appointments which have no end date using '...'
  existing, *positive_examples = %q{
     *====*    This appointment exists in the database.

      ====...  This and subsequent appointments are expected to overlap with the existing one.
     *====...
    =*====...
      ====
    =*====*=
     *====
     *====*
     *====*=
      ====*
    =*====*
    =*====
      ====*=
  }.split("\n").reject(&:blank?)

  existing_continuing, *positive_continuing_examples = %q{
     *====...    (existing appointment)

      ====       (expected to overlap with existing appointment)
    =*====
     *====
      ====...
    =*====...
     *====...
  }.split("\n").reject(&:blank?)

  # The negative examples are cases not expected to overlap with the existing appointment
  _, *negative_examples = %q{
     *====*      (existing appointment)

          *====  (not expected to overlap, ended_at is not inclusive)
          *====...
           ====
           ====...
  ===*
  ===
  }.split("\n").reject(&:blank?)

  _, *negative_continuing_examples = %q{
     *====...     (existing appointment)

   ==             (not expected to overlap)
  }.split("\n").reject(&:blank?)

  def dates_from_example(example)
    reference_date = 100.days.ago
    start_offset = example.index(/[^ ]/)
    if example.index("...")
      [reference_date + start_offset.days, nil]
    else
      end_offest = example.index(/($| )/, start_offset) - 1
      [reference_date + start_offset.days, reference_date + end_offest.days]
    end
  end

  test "can work out start and end date" do
    assert_equal [98.days.ago, 95.days.ago], dates_from_example("  *==*  ")
  end

  test "can work out start and end date for continuing examples" do
    assert_equal [98.days.ago, nil], dates_from_example("  *==...  ")
  end

  def appointment_attributes_from_dates(dates, role)
    attributes = {role: role, started_at: dates.first, ended_at: dates.last}
    if dates.last.nil?
      attributes.merge(make_current: true)
    else
      attributes
    end
  end

  def create_existing_appointment_and_build_example(existing, example)
    existing_date_range = dates_from_example(existing)
    example_date_range = dates_from_example(example)
    role = create(:role)
    create(:role_appointment, appointment_attributes_from_dates(existing_date_range, role))
    build(:role_appointment, appointment_attributes_from_dates(example_date_range, role))
  end

  def self.assert_overlapping_examples(existing, examples)
    examples.each do |example|
      test "should detect that #{existing} overlaps with #{example}" do
        appointment = create_existing_appointment_and_build_example(existing, example)
        assert appointment.overlaps_any?
      end
    end
  end

  assert_overlapping_examples(existing, positive_examples)
  assert_overlapping_examples(existing_continuing, positive_continuing_examples)

  def self.refute_overlapping_examples(existing, examples)
    examples.each do |example|
      test "should not detect any overlapping appointments between #{existing} and #{example}" do
        appointment = create_existing_appointment_and_build_example(existing, example)
        refute appointment.overlaps_any?
      end
    end
  end

  refute_overlapping_examples(existing, negative_examples)
  refute_overlapping_examples(existing_continuing, negative_continuing_examples)

  test "setting make_current should end the previous appointment when a new Person is appointed to a MinisterialRole" do
    alice = create(:person, forename: "Alice")
    bob = create(:person, forename: "Bob")

    role = create(:ministerial_role)

    original_appointment = create(:role_appointment, role: role, person: alice, started_at: 3.days.ago)

    assert_equal alice, role.current_person, "the minister should be alice"
    assert_equal [role], alice.current_roles, "alice should be the minister"
    assert_equal [], bob.current_roles, "bob should have no roles"

    create(:role_appointment, role: role, person: bob, started_at: 1.day.ago, make_current: true)

    role.reload
    alice.reload
    bob.reload

    assert_equal [], alice.current_roles, "alice should no longer be the minister"
    assert_equal bob, role.current_person, "the minister should be bob"
    assert_equal [role], bob.current_roles, "bob should be the minister"
  end

  existing, *positive_before_examples = %q{
     *====*    This appointment exists in the database.

    =*====     This and subsequent appointments are expected to be before it
     *====
    =*====...
     *====...
  }.split("\n").reject(&:blank?)

  _, *negative_before_examples = %q{
     *====*    This appointment exists in the database.

      ====     This and subsequent appointments are expected to not be before it
      ====*
      ====*=
      ====...
      ====*...
      ====*=...
          *==
           ===
          *==...
           ===...
  }.split("\n").reject(&:blank?)

  positive_before_examples.each do |example|
    test "should detect that #{example} is before #{existing}" do
      appointment = create_existing_appointment_and_build_example(existing, example)
      assert appointment.before_any?
    end
  end

  negative_before_examples.each do |example|
    test "should detect that #{example} is not before #{existing}" do
      appointment = create_existing_appointment_and_build_example(existing, example)
      refute appointment.before_any?
    end
  end

  test "setting make_current should only result in a valid appointment if started_at is greater than all others" do
    role = create(:ministerial_role)
    original_appointment = create(:role_appointment, role: role, started_at: 3.days.ago)
    refute build(:role_appointment, role: role, started_at: 4.days.ago, make_current: true).valid?
  end

  test "should not overwrite ended_at if ended_at already set" do
    role = create(:role)
    existing_appointment = create(:role_appointment, role: role, started_at: 20.days.ago, ended_at: 10.days.ago)
    new_appointment = create(:role_appointment, role: role,  started_at: 5.days.ago, ended_at: nil, make_current: true)

    existing_appointment.reload
    assert_equal 10.days.ago, existing_appointment.ended_at
  end

  test "should set ended_at on existing appointment to started_at on new appointment" do
    role = create(:role)
    existing_appointment = create(:role_appointment, role: role, started_at: 20.days.ago, ended_at: nil, make_current: true)
    new_appointment = create(:role_appointment, role: role,  started_at: 10.days.ago, ended_at: nil, make_current: true)

    existing_appointment.reload
    assert_equal 10.days.ago, existing_appointment.ended_at
  end

  test "should be able to get editions associated with this appointment" do
    editions = [create(:published_policy), create(:published_news_article)]
    appointment = create(:role_appointment, editions: editions)
    assert_equal editions, appointment.editions
  end

  test "should be able to get news articles associated with this appointment" do
    editions = [create(:published_policy), create(:published_news_article)]
    appointment = create(:role_appointment, editions: editions)
    assert_equal editions[1..1], appointment.news_articles
  end

  test "should not be destroyable when it has speeches" do
    speech = create(:speech)
    appointment = speech.role_appointment
    refute appointment.destroyable?
    assert_equal false, appointment.destroy
  end

  test "should be destroyable when it has no speeches" do
    appointment = create(:role_appointment, speeches: [])
    assert appointment.destroyable?
    assert appointment.destroy
  end

  test "unsaved role appointment is a new appointment" do
    role_appointment = build(:role_appointment)
    assert_equal "new", role_appointment.type
  end

  test "saved role appointment without ended_at is a current appointment" do
    role_appointment = create(:role_appointment, started_at: 1.year.ago, ended_at: nil, make_current: true)
    assert_equal "current", role_appointment.type
  end

  test "saved role appointment with ended_at is previous appointment" do
    role_appointment = create(:role_appointment, started_at: 1.year.ago, ended_at: 1.day.ago)
    assert_equal "previous", role_appointment.type
  end

  test "can return only appointments for ministerial roles" do
    pm = create(:ministerial_role)
    deputy_pm = create(:ministerial_role)
    some_other_role = create(:role)
    first_pm_appt = create(:role_appointment, role: pm, started_at: 10.days.ago, ended_at: 9.days.ago)
    deputy_pm_appt = create(:role_appointment, role: deputy_pm, started_at: 12.days.ago)
    other_appt = create(:role_appointment, role: some_other_role, started_at: 3.days.ago)
    second_pm_appt = create(:role_appointment, role: pm, started_at: 8.days.ago)

    assert_same_elements [first_pm_appt, deputy_pm_appt, second_pm_appt], RoleAppointment.for_ministerial_roles
  end

  test "current_at is only true if the appointment is current at the given date" do
    role_appointment = build(:role_appointment, started_at: 2.years.ago, ended_at: 1.year.ago)
    refute role_appointment.current_at(3.years.ago)
    assert role_appointment.current_at(18.months.ago)
    refute role_appointment.current_at(6.months.ago)
  end

  test "current_at is true for current appointments if the given date is newer than started_at" do
    role_appointment = build(:role_appointment, started_at: 2.years.ago, ended_at: nil)
    refute role_appointment.current_at(3.years.ago)
    assert role_appointment.current_at(18.months.ago)
    assert role_appointment.current_at(1.second.ago)
  end

  test "returns an historical account for the role and appointtee if one exists" do
    role_appointment = create(:historic_role_appointment)

    assert_nil role_appointment.historical_account

    historical_account = create(:historical_account, roles: [role_appointment.role], person: role_appointment.person)
    assert_equal historical_account, role_appointment.reload.historical_account
  end

  test "does not return an historical account if the appointee has one for another role" do
    role_appointment   = create(:historic_role_appointment)
    second_appointment = create(:historic_role_appointment, person: role_appointment.person)
    create(:historical_account, roles: [second_appointment.role], person: role_appointment.person)

    assert_nil role_appointment.historical_account
  end

  test "can scope appointments between dates" do
    today       = create(:role_appointment, started_at: Time.zone.now)
    last_month  = create(:role_appointment, started_at: 1.month.ago)
    last_year   = create(:role_appointment, started_at: 1.year.ago)

    assert_equal [today], RoleAppointment.between(1.week.ago, Time.zone.now)
    assert_equal [last_month], RoleAppointment.between(2.months.ago, 1.week.ago)
    assert_equal [today, last_month, last_year], RoleAppointment.between(1.year.ago, Time.zone.now)
  end
end
