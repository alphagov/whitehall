require 'test_helper'

class DocumentRelationTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    document_relation = build(:document_relation)
    assert document_relation.valid?
  end

  test "should be invalid without a document id" do
    document_relation = build(:document_relation, document_id: nil)
    refute document_relation.valid?
  end

  test "should be invalid without a policy id" do
    document_relation = build(:document_relation, policy_id: nil)
    refute document_relation.valid?
  end

  test "should be invalid if more than one relation exists from one document to another" do
    existing_relation = create(:document_relation)
    relation = build(:document_relation,
      document: existing_relation.document,
      policy: existing_relation.policy
    )
    refute relation.valid?
  end

  test "should be valid if one document is related to two others" do
    document = create(:document)
    existing_relation = create(:document_relation, document: document)
    relation = build(:document_relation, document: document)
    assert relation.valid?
  end

  test "should be valid if one document is related from two others" do
    policy = create(:policy)
    existing_relation = create(:document_relation, policy: policy)
    relation = build(:document_relation, policy: policy)
    assert relation.valid?
  end

  test "should allow creation" do
    relation = build(:document_relation)
    assert_nothing_raised { relation.save }
  end

  test "should not allow modification" do
    relation = create(:document_relation)
    assert_raises(ActiveRecord::ReadOnlyRecord) do
      relation.update_attributes(updated_at: Time.zone.now)
    end
  end

  test "should allow destruction" do
    relation = create(:document_relation)
    assert_nothing_raised { relation.destroy }
  end
end