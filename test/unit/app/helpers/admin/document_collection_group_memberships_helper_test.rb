require "test_helper"

class Admin::DocumentCollectionGroupMembershipsHelperTest < ActionView::TestCase
  setup do
    @document_collection_group = build(:document_collection, :with_group).groups.first
  end

  test "document_collection_group_member_title should return title if membership is a non_whitehall_link" do
    non_whitehall_link = DocumentCollectionNonWhitehallLink.new(
      base_path: "GOVUK PATH",
      title: "GOVUK TITLE",
    )
    membership = @document_collection_group.memberships.build(non_whitehall_link:)
    assert_equal "GOVUK TITLE", document_collection_group_member_title(membership)
  end

  test "document_collection_group_member_title should return title if membership is a document" do
    edition = build(:edition, title: "DOC TITLE")
    document = build(:document, slug: "DOC PATH", latest_edition: edition)
    membership = @document_collection_group.memberships.build(document:)
    assert_equal "DOC TITLE", document_collection_group_member_title(membership)
  end

  test "document_collection_group_member_url should return full url if membership is a non_whitehall_link" do
    non_whitehall_link = DocumentCollectionNonWhitehallLink.new(
      base_path: "/GOVUK-PATH",
      title: "GOVUK TITLE",
    )
    membership = @document_collection_group.memberships.build(non_whitehall_link:)
    assert_equal "https://www.test.gov.uk/GOVUK-PATH", document_collection_group_member_url(membership)
  end

  test "document_collection_group_member_url should return public url if membership is a document" do
    edition = build(:edition, title: "DOC TITLE")
    document = build(:document, slug: "DOC-PATH", latest_edition: edition)
    membership = @document_collection_group.memberships.build(document:)
    assert_equal "https://www.test.gov.uk/government/generic-editions/DOC-PATH", document_collection_group_member_url(membership)
  end
end
