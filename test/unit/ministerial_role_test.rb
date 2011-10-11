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
    ministerial_role = build(:ministerial_role, name: "Treasury secretary", person: build(:person, name: "Frank"),
                        organisations: [
                          build(:organisation, name: "Department of Health"),
                          build(:organisation, name: "Department for Education")])
    assert_equal "Frank (Treasury secretary, Department of Health and Department for Education)", ministerial_role.to_s
  end

  test "should return the person, ministerial role and organisation names" do
    ministerial_role = build(:ministerial_role, name: "Treasury secretary", person: build(:person, name: "Frank"),
                        organisations: [build(:organisation, name: "Department of Health")])
    assert_equal "Frank (Treasury secretary, Department of Health)", ministerial_role.to_s
  end

  test "should return the person and ministerial role names when there are no organisations" do
    ministerial_role = build(:ministerial_role, name: "Treasury secretary", person: build(:person, name: "Frank"),
                        organisations: [])
    assert_equal "Frank (Treasury secretary)", ministerial_role.to_s
  end

  test "should return the ministerial role and organisation names when person is missing" do
    ministerial_role = build(:ministerial_role, name: "Treasury secretary", person: nil,
                        organisations: [build(:organisation, name: "Department of Health")])
    assert_equal "Treasury secretary, Department of Health", ministerial_role.to_s
  end

  test "should return the ministerial role and all organisation names when person is missing" do
    ministerial_role = build(:ministerial_role, name: "Treasury secretary", person: nil,
                        organisations: [
                          build(:organisation, name: "Department of Health"),
                          build(:organisation, name: "Department for Education")])
    assert_equal "Treasury secretary, Department of Health and Department for Education", ministerial_role.to_s
  end

  test "should return the ministerial role name when person and organisations are missing" do
    ministerial_role = build(:ministerial_role, name: "Treasury secretary", person: nil, organisations: [])
    assert_equal "Treasury secretary", ministerial_role.to_s
  end
end