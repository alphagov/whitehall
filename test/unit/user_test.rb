require "test_helper"
require "gds-sso/lint/user_test"

class GDS::SSO::Lint::UserTest
  def user_class
    ::User
  end

  setup do
    @lint_user = user_class.new(name: "Test User", uid: "12345")
  end
end

class UserTest < ActiveSupport::TestCase
  test "#organisation_content_id is empty with no associated organisation" do
    user = build(:user, organisation: nil)

    assert user.organisation_content_id.empty?
  end

  test "#organisation_content_id is correct with associated organisation" do
    user = build(:user, organisation: build(:organisation, content_id: "example"))

    assert_equal user.organisation.content_id, user.organisation_content_id
  end

  test "should be invalid without a name" do
    user = build(:user, name: nil)
    assert_not user.valid?
  end

  test "should be a departmental editor if has whitehall Editor role" do
    user = build(:user, permissions: [User::Permissions::DEPARTMENTAL_EDITOR])
    assert user.departmental_editor?
    assert_equal "Departmental Editor", user.role
  end

  test "should not be a departmental editor if does not have has whitehall Editor role" do
    user = build(:user, permissions: [])
    assert_not user.departmental_editor?
  end

  test "should be a managing editor if has whitehall Managing Editor role" do
    user = build(:user, permissions: [User::Permissions::MANAGING_EDITOR])
    assert user.managing_editor?
    assert_equal "Managing Editor", user.role
  end

  test "should not be a managing editor if does not have has whitehall Managing Editor role" do
    user = build(:user, permissions: [])
    assert_not user.managing_editor?
  end

  test "should be a GDS editor if has whitehall GDS Editor role" do
    user = build(:user, permissions: [User::Permissions::GDS_EDITOR])
    assert user.gds_editor?
    assert_equal "GDS Editor", user.role
  end

  test "should not be a GDS editor if does not have has whitehall GDS Editor role" do
    user = build(:user, permissions: [])
    assert_not user.gds_editor?
  end

  test "should be a world editor if has whitehall World Editor role" do
    user = build(:user, permissions: [User::Permissions::WORLD_EDITOR])
    assert user.world_editor?
    assert_equal "World Editor", user.role
  end

  test "should not be a world editor if does not have has whitehall World Editor role" do
    user = build(:user, permissions: [])
    assert_not user.world_editor?
  end

  test "should be a world writer if has whitehall World Editor role" do
    user = build(:user, permissions: [User::Permissions::WORLD_WRITER])
    assert user.world_writer?
    assert_equal "World Writer", user.role
  end

  test "should not be a world writer if does not have has whitehall World Writer role" do
    user = build(:user, permissions: [])
    assert_not user.world_writer?
  end

  test "returns enabled users" do
    create(:disabled_user)
    user = create(:user)

    assert_equal 1, User.enabled.count
    assert_includes User.enabled, user
  end

  test "should not allow editing to just anyone" do
    user = build(:user)
    another_user = build(:user)
    assert_not user.editable_by?(another_user)
  end

  test "should not allow editing by themselves for the moment" do
    user = build(:user)
    assert_not user.editable_by?(user)
  end

  test "should allow editing by GDS Editor" do
    user = build(:user)
    gds_editor = build(:gds_editor)
    assert user.editable_by?(gds_editor)
  end

  test "cannot handle fatalities by default" do
    user = build(:user)
    assert_not user.can_handle_fatalities?
  end

  test "can handle fatalities if a GDS editor" do
    gds_editor = build(:gds_editor)
    assert gds_editor.can_handle_fatalities?
  end

  test "cannot force publish anything by default" do
    user = build(:user)
    assert_not user.can_force_publish_anything?
  end

  test "can force publish imports if given permission" do
    user = build(:user, permissions: [User::Permissions::FORCE_PUBLISH_ANYTHING])
    assert user.can_force_publish_anything?
  end

  test "cannot preview unreleased Design System changes by default" do
    user = build(:user)
    assert_not user.can_preview_design_system?
    assert_not user.can_preview_next_release?
  end

  test "can preview unreleased Design System changes if given permission" do
    user = build(:user, permissions: [User::Permissions::PREVIEW_DESIGN_SYSTEM])
    assert user.can_preview_design_system?
  end

  test "can preview the upcoming Design System release if given permission" do
    user = build(:user, permissions: [User::Permissions::PREVIEW_NEXT_RELEASE])
    assert user.can_preview_next_release?
  end

  test "cannot preview call for evidence by default" do
    user = build(:user)
    assert_not user.can_preview_call_for_evidence?
  end

  test "can preview call for evidence if given permission" do
    user = build(:user, permissions: [User::Permissions::PREVIEW_CALL_FOR_EVIDENCE])
    assert user.can_preview_call_for_evidence?
  end

  test "cannot use non legacy endpoints" do
    user = build(:user)
    assert_not user.can_use_non_legacy_endpoints?
  end

  test "can use non legacy endpoint if given permission" do
    user = build(:user, permissions: [User::Permissions::USE_NON_LEGACY_ENDPOINTS])
    assert user.can_use_non_legacy_endpoints?
  end

  test "can handle fatalities if our organisation is set to handle them" do
    not_allowed = build(:user, organisation: build(:organisation, handles_fatalities: false))
    assert_not not_allowed.can_handle_fatalities?
    user = build(:user, organisation: build(:organisation, handles_fatalities: true))
    assert user.can_handle_fatalities?
  end

  test "can be associated to world locations" do
    location1 = build(:world_location)
    location2 = build(:world_location)
    user = build(:user, world_locations: [location1, location2])
    assert_equal [location1, location2], user.world_locations
  end

  test "#fuzzy_last_name returns second word" do
    user = build(:user, name: "Joe Bloggs")
    assert_equal user.fuzzy_last_name, "Bloggs"
  end

  test "#fuzzy_last_name returns last words in name" do
    user = build(:user, name: "Joe van de Rijt")
    assert_equal user.fuzzy_last_name, "van de Rijt"
  end

  test "#fuzzy_last_name returns name if it is a single word" do
    user = build(:user, name: "Joe")
    assert_equal user.fuzzy_last_name, "Joe"
  end
end
