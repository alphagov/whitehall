require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    role = build(:role)
    assert role.valid?
  end

  test "should be invalid without a name" do
    role = build(:role, name: nil)
    refute role.valid?
  end
  
  test "should return the person, role and all organisation names" do
    role = build(:role, name: "Treasury secretary", person: build(:person, name: "Frank"),
                        organisations: [
                          build(:organisation, name: "Department of Health"),
                          build(:organisation, name: "Department for Education")])
    assert_equal "Frank (Treasury secretary, Department of Health and Department for Education)", role.to_s
  end

  test "should return the person, role and organisation names" do
    role = build(:role, name: "Treasury secretary", person: build(:person, name: "Frank"),
                        organisations: [build(:organisation, name: "Department of Health")])
    assert_equal "Frank (Treasury secretary, Department of Health)", role.to_s
  end

  test "should return the person and role names when there are no organisations" do
    role = build(:role, name: "Treasury secretary", person: build(:person, name: "Frank"),
                        organisations: [])
    assert_equal "Frank (Treasury secretary)", role.to_s
  end

  test "should return the role and organisation names when person is missing" do
    role = build(:role, name: "Treasury secretary", person: nil,
                        organisations: [build(:organisation, name: "Department of Health")])
    assert_equal "Treasury secretary, Department of Health", role.to_s
  end
  
  test "should return the role and all organisation names when person is missing" do
    role = build(:role, name: "Treasury secretary", person: nil,
                        organisations: [
                          build(:organisation, name: "Department of Health"),
                          build(:organisation, name: "Department for Education")])
    assert_equal "Treasury secretary, Department of Health and Department for Education", role.to_s
  end

  test "should return the role name when person and organisations are missing" do
    role = build(:role, name: "Treasury secretary", person: nil, organisations: [])
    assert_equal "Treasury secretary", role.to_s
  end
end