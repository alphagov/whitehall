require 'test_helper'

class MinisterialRoleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    ministerial_role = build(:ministerial_role)
    assert ministerial_role.valid?
  end

  test "should be invalid without a name" do
    ministerial_role = build(:ministerial_role, name: nil)
    refute ministerial_role.valid?
  end

  test "should return the person, ministerial role and all organisation names" do
    ministerial_role = create(:ministerial_role, name: "Treasury secretary", people: [create(:person, name: "Frank")],
                        organisations: [
                          create(:organisation, name: "Department of Health"),
                          create(:organisation, name: "Department for Education")])
    assert_equal "Frank (Treasury secretary, Department of Health and Department for Education)", ministerial_role.to_s
  end

  test "should return the person, ministerial role and organisation names" do
    ministerial_role = create(:ministerial_role, name: "Treasury secretary", people: [create(:person, name: "Frank")],
                        organisations: [create(:organisation, name: "Department of Health")])
    assert_equal "Frank (Treasury secretary, Department of Health)", ministerial_role.to_s
  end

  test "should return the person and ministerial role names when there are no organisations" do
    ministerial_role = create(:ministerial_role, name: "Treasury secretary", people: [create(:person, name: "Frank")],
                        organisations: [])
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
    ministerial_role = create(:ministerial_role, people: [create(:person, name: "Bob")])
    assert_equal "Bob", ministerial_role.person_name
  end

  test "should indicate that the role is vacant" do
    ministerial_role = create(:ministerial_role, people: [])
    assert_equal "No one is assigned to this role", ministerial_role.person_name
  end

  test "can return the set of ministers in alphabetical order" do
    charlie = create(:ministerial_role, people: [create(:person, name: "Charlie Parker")])
    alphonse = create(:ministerial_role, people: [create(:person, name: "Alphonse Ziller")])
    boris = create(:ministerial_role, people: [create(:person, name: "Boris Swingler")])

    assert_equal [alphonse, boris, charlie], MinisterialRole.alphabetical_by_person
  end
end