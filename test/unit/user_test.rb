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
  end

  test 'should not be a departmental editor if does not have has whitehall Editor role' do
    user = build(:user, permissions: [])
    refute user.departmental_editor?
  end

  test 'should be a GDS editor if has whitehall GDS Editor role' do
    user = build(:user, permissions: [User::Permissions::GDS_EDITOR])
    assert user.gds_editor?
  end

  test 'should not be a GDS editor if does not have has whitehall GDS Editor role' do
    user = build(:user, permissions: [])
    refute user.gds_editor?
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

  test 'can handle fatalities if our organisation is set to handle them' do
    not_allowed = build(:user, organisation: build(:organisation, handles_fatalities: false))
    refute not_allowed.can_handle_fatalities?
    user = build(:user, organisation: build(:organisation, handles_fatalities: true))
    assert user.can_handle_fatalities?
  end

  test 'can upload executables if it has the required permissions' do
    user = build(:user)
    refute user.can_upload_executable_attachments?

    user.permissions << User::Permissions::UPLOAD_EXECUTABLE_ATTACHMENTS
    assert user.can_upload_executable_attachments?
  end
end
