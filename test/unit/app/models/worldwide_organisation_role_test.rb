require "test_helper"

class WorldwideOrganisationRoleTest < ActiveSupport::TestCase
  test "should be invalid without a worldwide organisation" do
    organisation_role = build(:worldwide_organisation_role, worldwide_organisation_id: nil)
    assert_not organisation_role.valid?
  end

  test "should be invalid without a role" do
    organisation_role = build(:worldwide_organisation_role, role_id: nil)
    assert_not organisation_role.valid?
  end

  test "creating a new worldwide organisation role republished the linked worldwide orgaisation" do
    worldwide_organisation = create(:worldwide_organisation)
    role = create(:role)

    Whitehall::PublishingApi.expects(:republish_async).with(worldwide_organisation).once

    create(:worldwide_organisation_role, worldwide_organisation:, role:)
  end

  test "updating an existing worldwide organisation role republished the linked worldwide orgaisation" do
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_organisation_role = create(:worldwide_organisation_role, worldwide_organisation:)
    new_role = create(:role)

    Whitehall::PublishingApi.expects(:republish_async).with(worldwide_organisation).once

    worldwide_organisation_role.update!(role: new_role)
  end

  test "deleting a worldwide organisation role republished the linked worldwide orgaisation" do
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_organisation_role = create(:worldwide_organisation_role, worldwide_organisation:)

    Whitehall::PublishingApi.expects(:republish_async).with(worldwide_organisation).once

    worldwide_organisation_role.destroy!
  end
end
