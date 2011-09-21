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
  
  test 'should only return the draft policies' do
    draft_policy = Factory.create(:draft_policy)
    submitted_policy = Factory.create(:submitted_policy)
    assert_equal [draft_policy], Policy.drafts
  end
  
  test 'should only return the submitted policies' do
    draft_policy = Factory.create(:draft_policy)
    submitted_policy = Factory.create(:submitted_policy)
    assert_equal [submitted_policy], Policy.submitted
  end
end