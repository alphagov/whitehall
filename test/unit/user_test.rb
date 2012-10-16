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
    user = build(:user, permissions: {'Whitehall' => [User::Permissions::DEPARTMENTAL_EDITOR]})
    assert user.departmental_editor?
  end

  test 'should not be a departmental editor if does not have has whitehall Editor role' do
    user = build(:user, permissions: {'Whitehall' => []})
    refute user.departmental_editor?
  end

  test 'should not normally allow mass assignment of permissions' do
    user = build(:user, permissions: {'Whitehall' => []})
    user.assign_attributes(permissions: {'Whitehall' => ['Superuser']})
    assert_equal [], user.permissions['Whitehall']
  end

  test 'should allow gds-sso to mass assign permissions' do
    user = build(:user, permissions: {'Whitehall' => []})
    user.assign_attributes({permissions: {'Whitehall' => ['Superuser']}}, as: :oauth)
    assert_equal ['Superuser'], user.permissions['Whitehall']
  end
end