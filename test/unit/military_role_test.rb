require 'test_helper'

class MilitaryRoleTest < ActiveSupport::TestCase
  test "can never be a permanent secretary" do
    military_role = build(:military_role, permanent_secretary: true)
    refute military_role.permanent_secretary?
    refute military_role.permanent_secretary
  end

  test "can never be a cabinet member" do
    military_role = build(:military_role, cabinet_member: true)
    refute military_role.cabinet_member?
    refute military_role.cabinet_member
  end
end