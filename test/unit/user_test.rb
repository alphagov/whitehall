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
    user = build(:user, email: nil, permissions: {'Whitehall' => ['Editor']})
    assert user.departmental_editor?
  end

  test 'should not be a departmental editor if does not have has whitehall Editor role' do
    user = build(:user, email: nil, permissions: {'Whitehall' => []})
    refute user.departmental_editor?
  end
end