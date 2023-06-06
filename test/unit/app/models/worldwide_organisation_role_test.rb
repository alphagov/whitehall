require "test_helper"

class WorldwideOfficeRoleTest < ActiveSupport::TestCase
  test "should be invalid without a worldwide organisation" do
    organisation_role = build(:worldwide_organisation_role, worldwide_organisation_id: nil)
    assert_not organisation_role.valid?
  end

  test "should be invalid without a role" do
    organisation_role = build(:worldwide_organisation_role, role_id: nil)
    assert_not organisation_role.valid?
  end
end
