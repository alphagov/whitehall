require "test_helper"

class SupportingDocumentTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    supporting_document = build(:supporting_document)
    assert supporting_document.valid?
  end

  test "should be invalid without a title" do
    supporting_document = build(:supporting_document, title: nil)
    refute supporting_document.valid?
  end

  test "should be invalid without a body" do
    supporting_document = build(:supporting_document, body: nil)
    refute supporting_document.valid?
  end

  test "should be invalid without a document" do
    supporting_document = build(:supporting_document, document: nil)
    refute supporting_document.valid?
  end

  test "mark parent document as updated when supporting document is created" do
    parent_document = create(:draft_policy)
    lock_version = parent_document.lock_version

    supporting_document = create(:supporting_document, document: parent_document)

    refute_equal lock_version, parent_document.reload.lock_version
  end

  test "mark parent document as updated when supporting document is updated" do
    supporting_document = create(:supporting_document)
    parent_document = supporting_document.document
    lock_version = parent_document.lock_version

    supporting_document.update_attributes!(title: 'New title')

    refute_equal lock_version, parent_document.reload.lock_version
  end

  test "should set a slug from the supporting document title" do
    supporting_document = create(:supporting_document, title: 'Love all the people')
    assert_equal 'love-all-the-people', supporting_document.slug
  end

  test "should not change the slug when the title is changed" do
    supporting_document = create(:supporting_document, title: 'Love all the people')
    supporting_document.update_attributes(title: 'Hold hands')
    assert_equal 'love-all-the-people', supporting_document.slug
  end

  test "should concatenate words containing apostrophes" do
    supporting_document = create(:supporting_document, title: "Bob's bike")
    assert_equal 'bobs-bike', supporting_document.slug
  end
end