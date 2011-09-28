require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    user = build(:user)
    assert user.valid?
  end

  test 'should be invalid without a name' do
    user = build(:user, name: nil)
    assert_not user.valid?
  end
end