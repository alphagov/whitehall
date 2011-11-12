require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    role = build(:role)
    assert role.valid?
  end

  test "should be invalid without a name" do
    ministerial_role = build(:role, name: nil)
    refute ministerial_role.valid?
  end

  test "should return the person, ministerial role and all organisation names" do
    frank = create(:person, name: "Frank")
    ministerial_role = create(:ministerial_role, name: "Treasury secretary",
                        organisations: [
                          create(:organisation, name: "Department of Health"),
                          create(:organisation, name: "Department for Education")])
    create(:role_appointment, role: ministerial_role, person: frank)
    assert_equal "Frank (Treasury secretary, Department of Health and Department for Education)", ministerial_role.to_s
  end

  test "should return the person, ministerial role and organisation names" do
    frank = create(:person, name: "Frank")
    ministerial_role = create(:ministerial_role, name: "Treasury secretary",
                        organisations: [create(:organisation, name: "Department of Health")])
    create(:role_appointment, role: ministerial_role, person: frank)
    assert_equal "Frank (Treasury secretary, Department of Health)", ministerial_role.to_s
  end

  test "should return the person and ministerial role names when there are no organisations" do
    frank = create(:person, name: "Frank")
    ministerial_role = create(:ministerial_role, name: "Treasury secretary",
                        organisations: [])
    create(:role_appointment, role: ministerial_role, person: frank)
    assert_equal "Frank (Treasury secretary)", ministerial_role.to_s
  end

  test "should return the ministerial role and organisation names when person is missing" do
    ministerial_role = create(:ministerial_role, name: "Treasury secretary", people: [],
                        organisations: [create(:organisation, name: "Department of Health")])
    assert_equal "Treasury secretary, Department of Health", ministerial_role.to_s
  end

  test "should return the ministerial role and all organisation names when person is missing" do
    ministerial_role = create(:ministerial_role, name: "Treasury secretary", people: [],
                        organisations: [
                          create(:organisation, name: "Department of Health"),
                          create(:organisation, name: "Department for Education")])
    assert_equal "Treasury secretary, Department of Health and Department for Education", ministerial_role.to_s
  end

  test "should return the ministerial role name when person and organisations are missing" do
    ministerial_role = create(:ministerial_role, name: "Treasury secretary", people: [], organisations: [])
    assert_equal "Treasury secretary", ministerial_role.to_s
  end

  test "should return the person's name" do
    bob = create(:person, name: "Bob")
    ministerial_role = create(:ministerial_role)
    create(:role_appointment, role: ministerial_role, person: bob)
    assert_equal "Bob", ministerial_role.current_person_name
  end

  test "should indicate that the role is vacant" do
    ministerial_role = create(:ministerial_role, people: [])
    assert_equal "No one is assigned to this role", ministerial_role.current_person_name
  end

  test "can return the set of ministers in alphabetical order" do
    charlie_parker = create(:person, name: "Charlie Parker")
    alphonse_ziller = create(:person, name: "Alphonse Ziller")
    boris_swingler = create(:person, name: "Boris Swingler")

    charlie = create(:ministerial_role)
    alphonse = create(:ministerial_role)
    boris = create(:ministerial_role)

    create(:role_appointment, role: charlie, person: charlie_parker)
    create(:role_appointment, role: alphonse, person: alphonse_ziller)
    create(:role_appointment, role: boris, person: boris_swingler)

    assert_equal [alphonse, boris, charlie], MinisterialRole.alphabetical_by_person
  end

  test "should concatenate words containing apostrophes" do
    role = create(:ministerial_role, name: "Bob's bike")
    assert_equal 'bobs-bike', role.slug
  end

  test "should generate user-friendly types" do
    assert_equal "Ministerial", build(:ministerial_role).humanized_type
    assert_equal "Board member", build(:board_member_role).humanized_type
    assert_equal "Ministerial", MinisterialRole.humanized_type
    assert_equal "Board member", BoardMemberRole.humanized_type
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

  test "should not be destroyable when it is responsible for documents" do
    role = create(:role, documents: [create(:document)])
    refute role.destroyable?
    assert_equal false, role.destroy
  end

  test "should be destroyable when it has no appointments, organisations or documents" do
    role = create(:role, role_appointments: [], organisations: [], documents: [])
    assert role.destroyable?
    assert role.destroy
  end
end