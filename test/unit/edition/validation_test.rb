require "test_helper"

class Edition::ValidationTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should be invalid without a title" do
    edition = build(:edition, title: nil)
    refute edition.valid?
  end

  test "should be invalid without a body" do
    edition = build(:edition, body: nil)
    refute edition.valid?
  end

  test "should be invalid without an creator" do
    edition = build(:edition, creator: nil)
    refute edition.valid?
  end

  test "should be invalid without a document" do
    edition = build(:edition)
    edition.stubs(:document).returns(nil)
    refute edition.valid?
  end

  test "should be invalid when published without published_at" do
    edition = build(:published_edition, published_at: nil)
    refute edition.valid?
  end

  test "should be invalid when published without first_published_at" do
    edition = build(:published_edition, first_published_at: nil)
    refute edition.valid?
  end

  test "should be invalid if document has existing draft editions" do
    draft_edition = create(:draft_edition)
    edition = build(:edition, document: draft_edition.document)
    refute edition.valid?
  end

  test "should be invalid if document has existing submitted editions" do
    submitted_edition = create(:submitted_edition)
    edition = build(:edition, document: submitted_edition.document)
    refute edition.valid?
  end

  test "should be invalid if document has existing editions that need work" do
    rejected_edition = create(:rejected_edition)
    edition = build(:edition, document: rejected_edition.document)
    refute edition.valid?
  end

  test "should be invalid when published if document has existing published editions" do
    published_edition = create(:published_edition)
    edition = build(:published_policy, document: published_edition.document)
    refute edition.valid?
  end
end
