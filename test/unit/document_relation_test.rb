require 'test_helper'

class EditionRelationTest < ActiveSupport::TestCase
  test "should be invalid without a document id" do
    document_relation = build(:edition_relation, edition_id: nil)
    refute document_relation.valid?
  end

  test "should be invalid without a doc identity" do
    document_relation = build(:edition_relation, doc_identity: nil)
    refute document_relation.valid?
  end

  test "should be invalid if more than one relation exists from one document to another" do
    existing_relation = create(:edition_relation)
    relation = build(:edition_relation,
      edition: existing_relation.edition,
      doc_identity: existing_relation.doc_identity
    )
    refute relation.valid?
  end

  test "should be valid if one document is related to two others" do
    document = create(:edition)
    existing_relation = create(:edition_relation, edition: document)
    relation = build(:edition_relation, edition: document)
    assert relation.valid?
  end

  test "should be valid if one document is related from two others" do
    policy = create(:policy)
    existing_relation = create(:edition_relation, doc_identity: policy.doc_identity)
    relation = build(:edition_relation, doc_identity: policy.doc_identity)
    assert relation.valid?
  end

  test "should allow creation" do
    relation = build(:edition_relation)
    assert_nothing_raised { relation.save }
  end

  test "should not allow modification" do
    relation = create(:edition_relation)
    assert_raises(ActiveRecord::ReadOnlyRecord) do
      relation.update_attributes(updated_at: Time.zone.now)
    end
  end

  test "should allow destruction" do
    relation = create(:edition_relation)
    assert_nothing_raised { relation.destroy }
  end
end
