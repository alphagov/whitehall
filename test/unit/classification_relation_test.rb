require 'test_helper'

class ClassificationRelationTest < ActiveSupport::TestCase
  test "should be invalid without a topic id" do
    classification_relation = build(:classification_relation, classification_id: nil)
    assert_not classification_relation.valid?
  end

  test "should be invalid without a related topic id" do
    classification_relation = build(:classification_relation, related_classification_id: nil)
    assert_not classification_relation.valid?
  end

  test "should be invalid if more than one relation exists from one topic to another" do
    existing_relation = create(:classification_relation)
    relation = build(:classification_relation,
                     topic: existing_relation.topic,
                     related_topic: existing_relation.related_topic)
    assert_not relation.valid?
  end

  test "should be valid if one topic is related to two others" do
    topic = create(:topic)
    _existing_relation = create(:classification_relation, topic: topic)
    relation = build(:classification_relation, topic: topic)
    assert relation.valid?
  end

  test "should be valid if one topic is related from two others" do
    topic = create(:topic)
    _existing_relation = create(:classification_relation, related_topic: topic)
    relation = build(:classification_relation, related_topic: topic)
    assert relation.valid?
  end

  test "should be invalid if a topic is related to itself" do
    topic = create(:topic)
    relation = build(:classification_relation, topic: topic, related_topic: topic)
    assert_not relation.valid?
    assert relation.errors[:classification].include?("cannot relate to itself"), relation.errors.full_messages.join(", ")
  end

  test "should create inverse relation on create" do
    relation = create(:classification_relation)
    assert_not_nil relation.inverse_relation
  end

  test "should destroy inverse relation on destroy" do
    relation = create(:classification_relation)
    relation.destroy
    assert_nil relation.inverse_relation
  end

  test "should allow creation" do
    relation = build(:classification_relation)
    assert_nothing_raised { relation.save }
  end

  test "should allow destruction" do
    relation = create(:classification_relation)
    assert_nothing_raised { relation.destroy }
  end
end
