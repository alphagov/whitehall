require 'test_helper'

class BoardMemberRoleTest < ActiveSupport::TestCase
  test "can never be a cabinet member" do
    board_member_role = build(:board_member_role, cabinet_member: true)
    refute board_member_role.cabinet_member?
    refute board_member_role.cabinet_member
  end

  test "can never be a chief of the defence staff" do
    board_member_role = build(:board_member_role, chief_of_the_defence_staff: true)
    refute board_member_role.chief_of_the_defence_staff?
    refute board_member_role.chief_of_the_defence_staff
  end
end