require "test_helper"

class Admin::DocumentCollectionGroupMembershipsHelperTest < ActionView::TestCase
  setup do
    @document_collection_group = build(:document_collection, :with_group).groups.first
  end

  test "#document_collection_group_member_title should return title if membership is a non_whitehall_link" do
    non_whitehall_link = DocumentCollectionNonWhitehallLink.new(
      base_path: "GOVUK PATH",
      title: "GOVUK TITLE",
    )
    membership = @document_collection_group.memberships.build(non_whitehall_link:)
    assert_equal "GOVUK TITLE", document_collection_group_member_title(membership)
  end

  test "#document_collection_group_member_title should return title if membership is a document" do
    edition = build(:edition, title: "DOC TITLE")
    document = build(:document, slug: "DOC PATH", latest_edition: edition)
    membership = @document_collection_group.memberships.build(document:)
    assert_equal "DOC TITLE", document_collection_group_member_title(membership)
  end

  test "#document_collection_group_member_url should return full url if membership is a non_whitehall_link" do
    non_whitehall_link = DocumentCollectionNonWhitehallLink.new(
      base_path: "/GOVUK-PATH",
      title: "GOVUK TITLE",
    )
    membership = @document_collection_group.memberships.build(non_whitehall_link:)
    assert_equal "https://www.test.gov.uk/GOVUK-PATH", document_collection_group_member_url(membership)
  end

  test "#document_collection_group_member_url should return public url if membership is a document" do
    edition = build(:edition, title: "DOC TITLE")
    document = build(:document, slug: "DOC-PATH", latest_edition: edition)
    membership = @document_collection_group.memberships.build(document:)
    assert_equal "https://www.test.gov.uk/government/generic-editions/DOC-PATH", document_collection_group_member_url(membership)
  end

  test "#document_collection_group_member_unavailable? should return true if membership is a document without a latest_edition" do
    document = build(:document, slug: "DOC PATH", latest_edition: nil)
    membership = @document_collection_group.memberships.build(document:)
    assert_equal true, document_collection_group_member_unavailable?(membership)
  end

  test "#document_collection_group_member_unavailable? should return false if membership is a document with a latest_edition" do
    edition = build(:edition, title: "DOC TITLE")
    document = build(:document, slug: "DOC PATH", latest_edition: edition)
    membership = @document_collection_group.memberships.build(document:)
    assert_equal false, document_collection_group_member_unavailable?(membership)
  end

  test "#document_collection_group_member_unavailable? should return false if membership is a non_whitehall_link" do
    non_whitehall_link = DocumentCollectionNonWhitehallLink.new(
      base_path: "GOVUK PATH",
      title: "GOVUK TITLE",
    )
    membership = @document_collection_group.memberships.build(non_whitehall_link:)
    assert_equal false, document_collection_group_member_unavailable?(membership)
  end

  test "#unavailable_document_count should return the number of documents without editions" do
    document = build(:document, slug: "DOC PATH", latest_edition: nil)
    @document_collection_group.memberships.build(document:)
    @document_collection_group.memberships.build(document:)
    assert_equal 2, unavailable_document_count(@document_collection_group.memberships)
  end

  test "#unavailable_document_count should return 0 if there are documents with editions" do
    edition = build(:edition, title: "DOC TITLE")
    document = build(:document, slug: "DOC PATH", latest_edition: edition)
    @document_collection_group.memberships.build(document:)
    assert_equal 0, unavailable_document_count(@document_collection_group.memberships)
  end

  test "#unavailable_document_count should not count non_whitehall_links" do
    non_whitehall_link = DocumentCollectionNonWhitehallLink.new(
      base_path: "GOVUK PATH",
      title: "GOVUK TITLE",
    )
    @document_collection_group.memberships.build(non_whitehall_link:)
    assert_equal 0, unavailable_document_count(@document_collection_group.memberships)
  end
end
