require 'test_helper'

class RoleTypePresenterTest < PresenterTestCase
  test "should generate grouped options for select" do
    expected = [
      ["Managerial", [
        ["Permanent secretary", "permanent_secretary"],
        ["Board level manager", "board_level_manager"],
        ["Chief scientific advisor", "chief_scientific_advisor"]
      ]],
      ["DFT only", [
        ["Traffic commissioner", "traffic_commissioner"],
      ]],
      ["MOD only", [
        ["Chief of the defence staff", "chief_of_the_defence_staff"],
        ["Chief of staff", "chief_of_staff"]
      ]],
      ["FCO only", [
        ["Special representative", "special_representative"]
      ]],
      ["DH only", [
        ["Chief professional officer", "chief_professional_officer"],
      ]],
      ["Worldwide orgs only", [
        ["Ambassador", "ambassador"],
        ["High commissioner", "high_commissioner"],
        ["Governor", "governor"],
        ["Deputy head of mission", "deputy_head_of_mission"],
        ["Worldwide office staff", "worldwide_office_staff"]
      ]],
      ["MOJ only", [
        ["Judge", "judge"],
      ]],
      ["Ministerial", [
        ["Cabinet minister", "cabinet_minister"],
        ["Minister", "minister"]
      ]]
    ]
    assert_equal expected, RoleTypePresenter.options
  end

  test "should select cabinet minister" do
    role = Role.new(cabinet_member: true)
    assert_equal "cabinet_minister", RoleTypePresenter.option_value_for(role, "MinisterialRole")
  end

  test "should select minister" do
    role = Role.new(cabinet_member: false)
    assert_equal "minister", RoleTypePresenter.option_value_for(role, "MinisterialRole")
  end

  test "should select permanent secretary" do
    role = Role.new(permanent_secretary: true)
    assert_equal "permanent_secretary", RoleTypePresenter.option_value_for(role, "BoardMemberRole")
  end

  test "should select board board level manager" do
    role = Role.new(permanent_secretary: false)
    assert_equal "board_level_manager", RoleTypePresenter.option_value_for(role, "BoardMemberRole")
  end

  test "should select chief of the defence staff" do
    role = Role.new(chief_of_the_defence_staff: true)
    assert_equal "chief_of_the_defence_staff", RoleTypePresenter.option_value_for(role, "MilitaryRole")
  end

  test "should select chief of staff" do
    role = Role.new(chief_of_the_defence_staff: false)
    assert_equal "chief_of_staff", RoleTypePresenter.option_value_for(role, "MilitaryRole")
  end

  test "should select ambassador" do
    role = Role.new
    assert_equal "ambassador", RoleTypePresenter.option_value_for(role, "AmbassadorRole")
  end

  test "should select governor" do
    role = Role.new
    assert_equal "governor", RoleTypePresenter.option_value_for(role, "GovernorRole")
  end

  test "should select high commissioner" do
    role = Role.new
    assert_equal "high_commissioner", RoleTypePresenter.option_value_for(role, "HighCommissionerRole")
  end

  test "should select deputy head of state" do
    role = Role.new
    assert_equal "deputy_head_of_mission", RoleTypePresenter.option_value_for(role, "DeputyHeadOfMissionRole")
  end

  test "should select worldwide office staff" do
    role = Role.new
    assert_equal "worldwide_office_staff", RoleTypePresenter.option_value_for(role, "WorldwideOfficeStaffRole")
  end

  test "should have no default selection" do
    role = Role.new
    assert_nil RoleTypePresenter.option_value_for(role, "Role")
  end

  test "should generate attributes for cabinet minister" do
    expected = { type: "MinisterialRole", cabinet_member: true, permanent_secretary: false, chief_of_the_defence_staff: false }
    assert_equal expected, RoleTypePresenter.role_attributes_from("cabinet_minister")
  end

  test "should generate attributes for minister" do
    expected = { type: "MinisterialRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: false }
    assert_equal expected, RoleTypePresenter.role_attributes_from("minister")
  end

  test "should generate attributes for permanent secretary" do
    expected = { type: "BoardMemberRole", cabinet_member: false, permanent_secretary: true, chief_of_the_defence_staff: false }
    assert_equal expected, RoleTypePresenter.role_attributes_from("permanent_secretary")
  end

  test "should generate attributes for board member" do
    expected = { type: "BoardMemberRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: false }
    assert_equal expected, RoleTypePresenter.role_attributes_from("board_level_manager")
  end

  test "should generate attributes for chief of the defence staff" do
    expected = { type: "MilitaryRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: true }
    assert_equal expected, RoleTypePresenter.role_attributes_from("chief_of_the_defence_staff")
  end

  test "should generate attributes for chief of staff" do
    expected = { type: "MilitaryRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: false }
    assert_equal expected, RoleTypePresenter.role_attributes_from("chief_of_staff")
  end

  test "should generate attributes for chief professional officers" do
    expected = { type: "ChiefProfessionalOfficerRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: false }
    assert_equal expected, RoleTypePresenter.role_attributes_from("chief_professional_officer")
  end

  test "should generate attributes for FCO special representative" do
    expected = { type: "SpecialRepresentativeRole", cabinet_member: false, permanent_secretary: false, chief_of_the_defence_staff: false }
    assert_equal expected, RoleTypePresenter.role_attributes_from("special_representative")
  end

  test "should be blank by default" do
    expected = {}
    assert_equal expected, RoleTypePresenter.role_attributes_from(nil)
  end
end
