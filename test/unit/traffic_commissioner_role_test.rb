require 'test_helper'

class TrafficCommissionerRoleTest < ActiveSupport::TestCase
  test "can never be a permanent secretary" do
    traffic_commissioner_role = build(:traffic_commissioner_role, permanent_secretary: true)
    refute traffic_commissioner_role.permanent_secretary?
    refute traffic_commissioner_role.permanent_secretary
  end

  test "can never be a cabinet member" do
    traffic_commissioner_role = build(:traffic_commissioner_role, cabinet_member: true)
    refute traffic_commissioner_role.cabinet_member?
    refute traffic_commissioner_role.cabinet_member
  end
end
