require 'test_helper'

class PolicyTopicRelationTest < ActiveSupport::TestCase
  test "should be invalid without a policy topic id" do
    policy_topic_relation = build(:policy_topic_relation, policy_topic_id: nil)
    refute policy_topic_relation.valid?
  end

  test "should be invalid without a related policy topic id" do
    policy_topic_relation = build(:policy_topic_relation, related_policy_topic_id: nil)
    refute policy_topic_relation.valid?
  end

  test "should be invalid if more than one relation exists from one policy topic to another" do
    existing_relation = create(:policy_topic_relation)
    relation = build(:policy_topic_relation,
      policy_topic: existing_relation.policy_topic,
      related_policy_topic: existing_relation.related_policy_topic
    )
    refute relation.valid?
  end

  test "should be valid if one policy topic is related to two others" do
    policy_topic = create(:policy_topic)
    existing_relation = create(:policy_topic_relation, policy_topic: policy_topic)
    relation = build(:policy_topic_relation, policy_topic: policy_topic)
    assert relation.valid?
  end

  test "should be valid if one policy topic is related from two others" do
    policy_topic = create(:policy_topic)
    existing_relation = create(:policy_topic_relation, related_policy_topic: policy_topic)
    relation = build(:policy_topic_relation, related_policy_topic: policy_topic)
    assert relation.valid?
  end

  test "should be invalid if a policy topic is related to itself" do
    policy_topic = create(:policy_topic)
    relation = build(:policy_topic_relation, policy_topic: policy_topic, related_policy_topic: policy_topic)
    refute relation.valid?
    assert relation.errors[:policy_topic].include?("cannot relate to itself")
  end

  test "should create inverse relation on create" do
    relation = create(:policy_topic_relation)
    refute_nil relation.inverse_relation
  end

  test "should destroy inverse relation on destroy" do
    relation = create(:policy_topic_relation)
    relation.destroy
    assert_nil relation.inverse_relation
  end

  test "should allow creation" do
    relation = build(:policy_topic_relation)
    assert_nothing_raised { relation.save }
  end

  test "should not allow modification" do
    relation = create(:policy_topic_relation)
    assert_raises(ActiveRecord::ReadOnlyRecord) do
      relation.update_attributes(updated_at: Time.zone.now)
    end
  end

  test "should allow destruction" do
    relation = create(:policy_topic_relation)
    assert_nothing_raised { relation.destroy }
  end
end