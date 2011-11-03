require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    user = build(:user)
    assert user.valid?
  end

  test 'should be invalid without a name' do
    user = build(:user, name: nil)
    refute user.valid?
  end

  test 'should be invalid with an invalid email address' do
    user = build(:user, email_address: "invalid-email-address")
    refute user.valid?
  end

  test 'should be valid without an email address' do
    user = build(:user, email_address: nil)
    assert user.valid?
  end
end