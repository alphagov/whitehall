require 'test_helper'

class PolicyAreaRelationTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    policy_area_relation = build(:policy_area_relation)
    assert policy_area_relation.valid?
  end

  test "should be invalid without a policy area id" do
    policy_area_relation = build(:policy_area_relation, policy_area_id: nil)
    refute policy_area_relation.valid?
  end

  test "should be invalid without a related policy area id" do
    policy_area_relation = build(:policy_area_relation, related_policy_area_id: nil)
    refute policy_area_relation.valid?
  end

  test "should be invalid if more than one relation exists from one policy area to another" do
    existing_relation = create(:policy_area_relation)
    relation = build(:policy_area_relation,
      policy_area: existing_relation.policy_area,
      related_policy_area: existing_relation.related_policy_area
    )
    refute relation.valid?
  end

  test "should be valid if one policy area is related to two others" do
    policy_area = create(:policy_area)
    existing_relation = create(:policy_area_relation, policy_area: policy_area)
    relation = build(:policy_area_relation, policy_area: policy_area)
    assert relation.valid?
  end

  test "should be valid if one policy area is related from two others" do
    policy_area = create(:policy_area)
    existing_relation = create(:policy_area_relation, related_policy_area: policy_area)
    relation = build(:policy_area_relation, related_policy_area: policy_area)
    assert relation.valid?
  end

  test "should be invalid if a policy area is related to itself" do
    policy_area = create(:policy_area)
    relation = build(:policy_area_relation, policy_area: policy_area, related_policy_area: policy_area)
    refute relation.valid?
    assert relation.errors[:policy_area].include?("cannot relate to itself")
  end

  test "should create inverse relation on create" do
    relation = create(:policy_area_relation)
    refute_nil relation.inverse_relation
  end

  test "should destroy inverse relation on destroy" do
    relation = create(:policy_area_relation)
    relation.destroy
    assert_nil relation.inverse_relation
  end

  test "should allow creation" do
    relation = build(:policy_area_relation)
    assert_nothing_raised { relation.save }
  end

  test "should not allow modification" do
    relation = create(:policy_area_relation)
    assert_raises(ActiveRecord::ReadOnlyRecord) do
      relation.update_attributes(updated_at: Time.zone.now)
    end
  end

  test "should allow destruction" do
    relation = create(:policy_area_relation)
    assert_nothing_raised { relation.destroy }
  end
end