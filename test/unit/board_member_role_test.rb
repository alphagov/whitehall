require 'test_helper'

class BoardMemberRoleTest < ActiveSupport::TestCase
  test "should generate user-friendly types" do
    assert_equal "Board member", build(:board_member_role).humanized_type
    assert_equal "Board member", BoardMemberRole.humanized_type
  end
end