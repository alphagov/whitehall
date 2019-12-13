require "test_helper"

class BoardMemberRoleTest < ActiveSupport::TestCase
  test "should not be a cabinet member" do
    board_member_role = build(:board_member_role)
    assert_not board_member_role.cabinet_member?
  end

  test "should not be a chief of the defence staff" do
    board_member_role = build(:board_member_role)
    assert_not board_member_role.chief_of_the_defence_staff?
  end
end
