require 'test_helper'

class RoleTypePresenterTest < ActiveSupport::TestCase
  test "should generate grouped options for select" do
    expected = [
      ["Ministerial", [
        ["Cabinet minister", "cabinet_minister"],
        ["Minister", "minister"]
      ]],
      ["Managerial", [
        ["Permanent secretary", "permanent_secretary"],
        ["Board member", "board_member"]
      ]],
      ["Military", [
        ["Chief of the defence staff", "chief_of_the_defence_staff"],
        ["Chief of staff", "chief_of_staff"]
      ]]
    ]
    assert_equal expected, RoleTypePresenter.options
  end

  test "should select cabinet minister" do
    role = build(:role, cabinet_member: true)
    assert_equal "cabinet_minister", RoleTypePresenter.option_value_for(role, "MinisterialRole")
  end

  test "should select minister" do
    role = build(:role, cabinet_member: false)
    assert_equal "minister", RoleTypePresenter.option_value_for(role, "MinisterialRole")
  end

  test "should select permanent secretary" do
    role = build(:role, permanent_secretary: true)
    assert_equal "permanent_secretary", RoleTypePresenter.option_value_for(role, "BoardMemberRole")
  end

  test "should select board member" do
    role = build(:role, permanent_secretary: false)
    assert_equal "board_member", RoleTypePresenter.option_value_for(role, "BoardMemberRole")
  end

  test "should select chief of the defence staff" do
    role = build(:role, chief_of_the_defence_staff: true)
    assert_equal "chief_of_the_defence_staff", RoleTypePresenter.option_value_for(role, "MilitaryRole")
  end

  test "should select chief of staff" do
    role = build(:role, chief_of_the_defence_staff: false)
    assert_equal "chief_of_staff", RoleTypePresenter.option_value_for(role, "MilitaryRole")
  end

  test "should select cabinet minister by default" do
    role = build(:role)
    assert_equal "cabinet_minister", RoleTypePresenter.option_value_for(role, "Role")
  end

  test "should generate attributes for cabinet minister" do
    expected = {type: "MinisterialRole", cabinet_member: true, permanent_secretary: false, chief_of_the_defence_staff: false}
    assert_equal expected, RoleTypePresenter.role_attributes_from(type: "cabinet_minister")
  end

  test "should generate attributes for minister" do
    expected = {type: "MinisterialRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: false}
    assert_equal expected, RoleTypePresenter.role_attributes_from(type: "minister")
  end

  test "should generate attributes for permanent secretary" do
    expected = {type: "BoardMemberRole", cabinet_member: false, permanent_secretary: true, chief_of_the_defence_staff: false}
    assert_equal expected, RoleTypePresenter.role_attributes_from(type: "permanent_secretary")
  end

  test "should generate attributes for board member" do
    expected = {type: "BoardMemberRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: false}
    assert_equal expected, RoleTypePresenter.role_attributes_from(type: "board_member")
  end

  test "should generate attributes for chief of the defence staff" do
    expected = {type: "MilitaryRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: true}
    assert_equal expected, RoleTypePresenter.role_attributes_from(type: "chief_of_the_defence_staff")
  end

  test "should generate attributes for chief of staff" do
    expected = {type: "MilitaryRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: false}
    assert_equal expected, RoleTypePresenter.role_attributes_from(type: "chief_of_staff")
  end

  test "should generate attributes for cabinet minister by default" do
    expected = {type: "MinisterialRole", cabinet_member: true, permanent_secretary: false, chief_of_the_defence_staff: false}
    assert_equal expected, RoleTypePresenter.role_attributes_from(type: nil)
  end
end
