require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    role = build(:role)
    assert role.valid?
  end

  test "should be invalid without a name" do
    role = build(:role, name: nil)
    refute role.valid?
  end

  test "should be invalid with a duplicate name" do
    existing_role = create(:role)
    new_role = build(:role, name: existing_role.name)
    refute new_role.valid?
  end
end