require 'test_helper'

class EditionRelationTest < ActiveSupport::TestCase
  test "should be invalid without a edition_id" do
    edition_relation = build(:edition_relation, edition_id: nil)
    refute edition_relation.valid?
  end

  test "should be invalid without a document" do
    edition_relation = build(:edition_relation, document: nil)
    refute edition_relation.valid?
  end

  test "should be invalid if more than one relation exists from one edition to another" do
    existing_relation = create(:edition_relation)
    relation = build(:edition_relation,
      edition: existing_relation.edition,
      document: existing_relation.document
    )
    refute relation.valid?
  end

  test "should be valid if one edition is related to two others" do
    edition = create(:edition)
    existing_relation = create(:edition_relation, edition: edition)
    relation = build(:edition_relation, edition: edition)
    assert relation.valid?
  end

  test "should be valid if one edition is related from two others" do
    policy = create(:policy)
    existing_relation = create(:edition_relation, document: policy.document)
    relation = build(:edition_relation, document: policy.document)
    assert relation.valid?
  end

  test "should allow creation" do
    relation = build(:edition_relation)
    assert_nothing_raised { relation.save }
  end

  test "should allow destruction" do
    relation = create(:edition_relation)
    assert_nothing_raised { relation.destroy }
  end
end
