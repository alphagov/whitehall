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
end