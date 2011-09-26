require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    policy = Factory.build(:policy)
    assert policy.valid?
  end

  test 'should be invalid without a title' do
    policy = Factory.build(:policy, title: nil)
    assert_not policy.valid?
  end

  test 'should be invalid without a body' do
    policy = Factory.build(:policy, body: nil)
    assert_not policy.valid?
  end

  test 'should be invalid without an author' do
    policy = Factory.build(:policy, author: nil)
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

  test 'should not be publishable by the author' do
    author = Factory.create(:departmental_editor)
    policy = Factory.create(:policy, author: author)
    assert_not policy.publish_as!(author)
    assert_not policy.published?
    assert_equal ["You are not the second set of eyes"], policy.errors.full_messages
  end

  test 'should be publishable by departmental editors' do
    author = Factory.create(:policy_writer)
    policy = Factory.create(:policy, author: author)
    other_user = Factory.create(:departmental_editor)
    assert policy.publish_as!(other_user)
    assert policy.published?
  end

  test 'should not return published policies in submitted' do
    policy = Factory.create(:submitted_policy)
    policy.publish_as!(Factory.create(:departmental_editor))
    assert_not Policy.submitted.include?(policy)
  end

  test 'should not be publishable by normal users' do
    policy = Factory.create(:submitted_policy)
    assert_not policy.publish_as!(Factory.create(:policy_writer))
    assert_not policy.published?
    assert_equal ["Only departmental editors can publish policies"], policy.errors.full_messages
  end

  test 'should not be publishable if lock version is not current' do
    editor = Factory.create(:departmental_editor)
    policy = Factory.create(:policy, title: "old title")

    other_instance = Policy.find(policy.id)
    other_instance.update_attributes(title: "new title")

    assert_not policy.publish_as!(editor, policy.lock_version)
    assert_not Policy.find(policy.id).published?
    assert_equal ["This policy has been edited since you viewed it"], policy.errors.full_messages
  end
end