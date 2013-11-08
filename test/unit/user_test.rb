require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should be invalid without a name' do
    user = build(:user, name: nil)
    refute user.valid?
  end

  test 'should be invalid with an invalid email address' do
    user = build(:user, email: "invalid-email-address")
    refute user.valid?
  end

  test 'should be valid without an email address' do
    user = build(:user, email: nil)
    assert user.valid?
  end

  test 'should be a departmental editor if has whitehall Editor role' do
    user = build(:user, permissions: [User::Permissions::DEPARTMENTAL_EDITOR])
    assert user.departmental_editor?
    assert_equal 'Departmental Editor', user.role
  end

  test 'should not be a departmental editor if does not have has whitehall Editor role' do
    user = build(:user, permissions: [])
    refute user.departmental_editor?
  end

  test 'should be a managing editor if has whitehall Managing Editor role' do
    user = build(:user, permissions: [User::Permissions::MANAGING_EDITOR])
    assert user.managing_editor?
    assert_equal 'Managing Editor', user.role
  end

  test 'should not be a managing editor if does not have has whitehall Managing Editor role' do
    user = build(:user, permissions: [])
    refute user.managing_editor?
  end

  test 'should be a GDS editor if has whitehall GDS Editor role' do
    user = build(:user, permissions: [User::Permissions::GDS_EDITOR])
    assert user.gds_editor?
    assert_equal 'GDS Editor', user.role
  end

  test 'should not be a GDS editor if does not have has whitehall GDS Editor role' do
    user = build(:user, permissions: [])
    refute user.gds_editor?
  end

  test 'should be a world editor if has whitehall World Editor role' do
    user = build(:user, permissions: [User::Permissions::WORLD_EDITOR])
    assert user.world_editor?
    assert_equal 'World Editor', user.role
  end

  test 'should not be a world editor if does not have has whitehall World Editor role' do
    user = build(:user, permissions: [])
    refute user.world_editor?
  end

  test 'should be a world writer if has whitehall World Editor role' do
    user = build(:user, permissions: [User::Permissions::WORLD_WRITER])
    assert user.world_writer?
    assert_equal 'World Writer', user.role
  end

  test 'should not be a world writer if does not have has whitehall World Writer role' do
    user = build(:user, permissions: [])
    refute user.world_writer?
  end

  test 'should not normally allow mass assignment of permissions' do
    user = build(:user, permissions: [])
    user.assign_attributes(permissions: ['Superuser'])
    assert_equal [], user.permissions
  end

  test 'should allow gds-sso to mass assign permissions' do
    user = build(:user, permissions: [])
    user.assign_attributes({permissions: ['Superuser']}, as: :oauth)
    assert_equal ['Superuser'], user.permissions
  end

  test 'should not allow editing to just anyone' do
    user = build(:user)
    another_user = build(:user)
    refute user.editable_by?(another_user)
  end

  test 'should not allow editing by themselves for the moment' do
    user = build(:user)
    refute user.editable_by?(user)
  end

  test 'should allow editing by GDS Editor' do
    user = build(:user)
    gds_editor = build(:gds_editor)
    assert user.editable_by?(gds_editor)
  end

  test 'cannot handle fatalities by default' do
    user = build(:user)
    refute user.can_handle_fatalities?
  end

  test 'can handle fatalities if a GDS editor' do
    gds_editor = build(:gds_editor)
    assert gds_editor.can_handle_fatalities?
  end

  test 'cannot force publish anything by default' do
    user = build(:user)
    refute user.can_force_publish_anything?
  end

  test 'can force publish imports if given permission' do
    user = build(:user, permissions: [User::Permissions::FORCE_PUBLISH_ANYTHING])
    assert user.can_force_publish_anything?
  end

  test 'can handle fatalities if our organisation is set to handle them' do
    not_allowed = build(:user, organisation: build(:organisation, handles_fatalities: false))
    refute not_allowed.can_handle_fatalities?
    user = build(:user, organisation: build(:organisation, handles_fatalities: true))
    assert user.can_handle_fatalities?
  end

  test 'can be associated to world locations' do
    location = build(:world_location)
    location2 = build(:world_location)
    user = build(:user, world_locations: [location, location2])
    assert_equal [location, location2], user.world_locations
  end
end
