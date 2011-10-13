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
end