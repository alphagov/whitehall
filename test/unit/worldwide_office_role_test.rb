require 'test_helper'

class WorldwideOfficeRoleTest < ActiveSupport::TestCase
  test "should be invalid without a worldwide office" do
    organisation_role = build(:worldwide_office_role, worldwide_office_id: nil)
    refute organisation_role.valid?
  end

  test "should be invalid without a role" do
    organisation_role = build(:worldwide_office_role, role_id: nil)
    refute organisation_role.valid?
  end
end
