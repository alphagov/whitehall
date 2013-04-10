require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :responsibilities

  ['name', 'responsibilities'].each do |column_name|
    # These tests ensure that we're excluding the name and responsibilities columns from `Role.columns`.
    # You can safely remove the test, and Role.columns, once it's been deployed and we've subsequently removed
    # these columns for real.
    test "#columns excludes #{column_name} so that we can safely remove it from role in a future migration" do
      refute Role.columns.map(&:name).include?(column_name)
    end
  end

  test "should be invalid without a name" do
    role = build(:role, name: nil)
    refute role.valid?
  end

  test "should return the role and organisation name" do
    role = create(:role, name: "Treasury secretary", people: [],
                   organisations: [create(:organisation, name: "Department of Health")])
    assert_equal "Treasury secretary, Department of Health", role.to_s
  end

  test "should return the role and all organisation names" do
    role = create(:role, name: "Treasury secretary", people: [],
                   organisations: [
                     create(:organisation, name: "Department of Health"),
                     create(:organisation, name: "Department for Education")])
    assert_equal "Treasury secretary, Department of Health and Department for Education", role.to_s
  end

  test "should return the role name when organisations are missing" do
    role = create(:role_without_organisations, name: "Treasury secretary", people: [], organisations: [])
    assert_equal "Treasury secretary", role.to_s
  end

  test "should be able to get the current person" do
    bob = create(:person, forename: "Bob")
    role = create(:role)
    create(:role_appointment, role: role, person: bob)
    assert_equal bob, role.current_person
  end

  test "should be able to get previous appointments" do
    role = create(:role)
    create(:role_appointment, role: role, person: create(:person, forename: "Bob"), started_at: 1.day.ago, ended_at: nil)
    previous = create(:role_appointment, role: role, person: create(:person, forename: "Jane"), started_at: 2.days.ago, ended_at: 1.day.ago)
    assert_equal [previous], role.previous_appointments
  end

  test "should return the person's name" do
    bob = create(:person, forename: "Bob")
    role = create(:role)
    create(:role_appointment, role: role, person: bob)
    assert_equal "Bob", role.current_person_name
  end

  test "should return the person's surname" do
    bob = create(:person, forename: "Bob", surname: "Smith")
    role = create(:role)
    create(:role_appointment, role: role, person: bob)
    assert_equal "Smith", role.current_person_surname
  end

  test "should indicate that the role is vacant" do
    role = create(:role, people: [])
    assert_equal "No one is assigned to this role", role.current_person_name
  end

  test "can return the set of current appointees in alphabetical order by surname" do
    charlie_parker = create(:person, forename: "Charlie", surname: "Parker")
    alphonse_ziller = create(:person, forename: "Alphonse", surname: "Ziller")
    boris_swingler = create(:person, forename: "Boris", surname: "Swingler")

    parker = create(:role)
    ziller = create(:role)
    swingler = create(:role)

    create(:role_appointment, role: parker, person: charlie_parker)
    create(:role_appointment, role: ziller, person: alphonse_ziller)
    create(:role_appointment, role: swingler, person: boris_swingler)

    assert_equal [parker, swingler, ziller], Role.alphabetical_by_person
  end

  test 'should set a slug from the name' do
    role = create(:role, name: 'Prime Minister')
    assert_equal 'prime-minister', role.slug
  end

  test 'should not change the slug when the name is changed' do
    role = create(:role, name: 'Prime Minister')
    role.update_attributes(name: 'Chancellor of the Exchequer')
    assert_equal 'prime-minister', role.slug
  end

  test "should not include apostrophes in slug" do
    role = create(:role, name: "Bob's bike")
    assert_equal 'bobs-bike', role.slug
  end

  test "should not be destroyable when it has appointments" do
    role = create(:role, role_appointments: [create(:role_appointment)])
    refute role.destroyable?
    assert_equal false, role.destroy
  end

  test "should not be destroyable when it has organisations" do
    role = create(:role, organisations: [create(:organisation)])
    refute role.destroyable?
    assert_equal false, role.destroy
  end

  test "should not be destroyable when it has worldwide organisations" do
    role = create(:role_without_organisations, worldwide_organisations: [create(:worldwide_organisation)])
    refute role.destroyable?
    assert_equal false, role.destroy
  end

  test "should be destroyable when it has no appointments, organisations or woridwide organisations" do
    role = create(:role_without_organisations, role_appointments: [], organisations: [], worldwide_organisations: [])
    assert role.destroyable?
    assert role.destroy
  end

  test "should have seniority 100 to sort after cabinet roles" do
    role = build(:role)
    assert_equal 100, role.seniority
  end

  test "should have a payment type" do
    role = create(:role, role_payment_type_id: 1)
    assert_equal RolePaymentType.find_by_id(1), role.role_payment_type
  end

  test "should have a attendance type" do
    role = create(:role, attends_cabinet_type_id: 1)
    assert_equal RoleAttendsCabinetType.find_by_id(1), role.attends_cabinet_type
  end

  test "footnotes should be based on the role type and attendance type 2" do
    role = create(:role, attends_cabinet_type_id: 2, role_payment_type_id: 1)
    footnote = " <span>#{role.attends_cabinet_type.name}<span><sup>#{role.role_payment_footnote}</sup>"
    assert_equal footnote, role.footnotes
  end

  test "should be able to scope roles by whips" do
    role = create(:role, whip_organisation_id: 1)
    role2 = create(:role)
    assert_equal [role], Role.whip
  end

  test "should be able to scope roles by cabinet attendance" do
    role = create(:role, attends_cabinet_type_id: 1)
    role2 = create(:role)
    assert_equal [role], Role.also_attends_cabinet
  end

  test "has removeable translations" do
    role = create(:role, translated_into: [:fr, :es])
    role.remove_translations_for(:fr)
    refute role.translated_locales.include?(:fr)
    assert role.translated_locales.include?(:es)
  end
end
