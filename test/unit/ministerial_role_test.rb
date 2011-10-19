require 'test_helper'

class MinisterialRoleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    ministerial_role = build(:ministerial_role)
    assert ministerial_role.valid?
  end
end