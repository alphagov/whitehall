require 'test_helper'

class Admin::CabinetMinistersControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "create should reorder miniserial roles" do
    organisation = create(:organisation)
    role_3 = create(:board_member_role, name: 'Chief Griller', organisations: [organisation])
    role_2 = create(:ministerial_role, name: 'Non-Executive Director', cabinet_member: true, organisations: [organisation])
    role_1 = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true, organisations: [organisation])

    put :update, roles: {
      "#{role_1.id}" => {ordering: 0},
      "#{role_2.id}" => {ordering: 1},
    }

    assert_equal MinisterialRole.cabinet.order(:seniority).all, [role_1, role_2]
  end
end
