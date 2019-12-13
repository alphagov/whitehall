require "test_helper"

class TrafficCommissionerRoleTest < ActiveSupport::TestCase
  test "should not be a permanent secretary" do
    traffic_commissioner_role = build(:traffic_commissioner_role)
    assert_not traffic_commissioner_role.permanent_secretary?
  end

  test "should not be a cabinet member" do
    traffic_commissioner_role = build(:traffic_commissioner_role)
    assert_not traffic_commissioner_role.cabinet_member?
  end
end
