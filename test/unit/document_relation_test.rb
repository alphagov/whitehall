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

  test "should be invalid without a related document id" do
    document_relation = build(:document_relation, related_document_id: nil)
    refute document_relation.valid?
  end

  test "should be invalid if more than one relation exists from one document to another" do
    existing_relation = create(:document_relation)
    relation = build(:document_relation,
      document: existing_relation.document,
      related_document: existing_relation.related_document
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
    document = create(:document)
    existing_relation = create(:document_relation, related_document: document)
    relation = build(:document_relation, related_document: document)
    assert relation.valid?
  end

  test "should return relation with the opposite direction" do
    relation = create(:document_relation)
    inverse_relation = relation.inverse_relation
    assert_equal relation.document, inverse_relation.related_document
    assert_equal relation.related_document, inverse_relation.document
  end

  test "should create inverse relation on create" do
    relation = create(:document_relation)
    refute_nil relation.inverse_relation
  end

  test "should destroy inverse relation on destroy" do
    relation = create(:document_relation)
    relation.destroy
    assert_nil relation.inverse_relation
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