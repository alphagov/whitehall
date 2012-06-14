require 'test_helper'

class TopicRelationTest < ActiveSupport::TestCase
  test "should be invalid without a topic id" do
    topic_relation = build(:topic_relation, topic_id: nil)
    refute topic_relation.valid?
  end

  test "should be invalid without a related topic id" do
    topic_relation = build(:topic_relation, related_topic_id: nil)
    refute topic_relation.valid?
  end

  test "should be invalid if more than one relation exists from one topic to another" do
    existing_relation = create(:topic_relation)
    relation = build(:topic_relation,
      topic: existing_relation.topic,
      related_topic: existing_relation.related_topic
    )
    refute relation.valid?
  end

  test "should be valid if one topic is related to two others" do
    topic = create(:topic)
    existing_relation = create(:topic_relation, topic: topic)
    relation = build(:topic_relation, topic: topic)
    assert relation.valid?
  end

  test "should be valid if one topic is related from two others" do
    topic = create(:topic)
    existing_relation = create(:topic_relation, related_topic: topic)
    relation = build(:topic_relation, related_topic: topic)
    assert relation.valid?
  end

  test "should be invalid if a topic is related to itself" do
    topic = create(:topic)
    relation = build(:topic_relation, topic: topic, related_topic: topic)
    refute relation.valid?
    assert relation.errors[:topic].include?("cannot relate to itself")
  end

  test "should create inverse relation on create" do
    relation = create(:topic_relation)
    refute_nil relation.inverse_relation
  end

  test "should destroy inverse relation on destroy" do
    relation = create(:topic_relation)
    relation.destroy
    assert_nil relation.inverse_relation
  end

  test "should allow creation" do
    relation = build(:topic_relation)
    assert_nothing_raised { relation.save }
  end

  test "should not allow modification" do
    relation = create(:topic_relation)
    assert_raises(ActiveRecord::ReadOnlyRecord) do
      relation.update_attributes(updated_at: Time.zone.now)
    end
  end

  test "should allow destruction" do
    relation = create(:topic_relation)
    assert_nothing_raised { relation.destroy }
  end
end