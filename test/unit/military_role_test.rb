require "test_helper"

class MilitaryRoleTest < ActiveSupport::TestCase
  test "should not be a permanent secretary" do
    military_role = build(:military_role)
    assert_not military_role.permanent_secretary?
  end

  test "should not be a cabinet member" do
    military_role = build(:military_role)
    assert_not military_role.cabinet_member?
  end
end
