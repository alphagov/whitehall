require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    policy = Factory.build(:policy)
    assert policy.valid?
  end

  test 'should be invalid without a title' do
    policy = Factory.build(:policy, :title => nil)
    assert_not policy.valid?
  end

  test 'should be invalid without a body' do
    policy = Factory.build(:policy, :body => nil)
    assert_not policy.valid?
  end
end