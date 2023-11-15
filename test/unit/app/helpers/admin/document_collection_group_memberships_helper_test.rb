require "test_helper"

class Admin::DocumentCollectionGroupMembershipsHelperTest < ActionView::TestCase
  setup do
    @collection = build(:document_collection, :with_group)
    @group = @collection.groups.first
  end

  test "#document_collection_group_member_title should return title if membership is a non_whitehall_link" do
    non_whitehall_link = build(
      :document_collection_non_whitehall_link,
      base_path: "GOVUK PATH",
      title: "GOVUK TITLE",
    )
    membership = @group.memberships.build(non_whitehall_link:)
    assert_equal "GOVUK TITLE", document_collection_group_member_title(membership)
  end

  test "#document_collection_group_member_title should return title if membership is a document" do
    edition = build(:edition, title: "DOC TITLE")
    document = build(:document, slug: "DOC PATH", latest_edition: edition)
    membership = @group.memberships.build(document:)
    assert_equal "DOC TITLE", document_collection_group_member_title(membership)
  end

  test "#document_collection_group_member_title should return 'unavailable document' if membership is an unavailable document" do
    document = build(:document, slug: "DOC PATH", latest_edition: nil)
    membership = @group.memberships.build(document:)
    assert_match Admin::DocumentCollectionGroupMembershipsHelper::UNAVAILABLE_DOCUMENT_TITLE, document_collection_group_member_title(membership)
  end

  test "#document_collection_group_member_links should contain correct view and remove url for a non_whitehall_link" do
    non_whitehall_link = build(
      :document_collection_non_whitehall_link,
      base_path: "/GOVUK-PATH",
      title: "GOVUK TITLE",
    )
    membership = @group.memberships.build(non_whitehall_link:)

    @collection.save && @group.save && membership.save
    links = document_collection_group_member_links(@collection, @group, membership)

    assert_match "https://www.test.gov.uk/GOVUK-PATH", links
    assert_match confirm_destroy_admin_document_collection_group_document_collection_group_membership_path(@collection, @group, membership), links
  end

  test "#document_collection_group_member_links should contain correct view and remove url for a document" do
    edition = build(:edition, title: "DOC TITLE")
    document = build(:document, slug: "DOC-PATH", latest_edition: edition)
    membership = @group.memberships.build(document:)

    @collection.save && @group.save && membership.save
    links = document_collection_group_member_links(@collection, @group, membership)

    assert_match "https://www.test.gov.uk/government/generic-editions/DOC-PATH", links
    assert_match confirm_destroy_admin_document_collection_group_document_collection_group_membership_path(@collection, @group, membership), links
  end

  test "#document_collection_group_member_links should contain only remove url for an unavailable document" do
    document = build(:document, slug: "DOC-PATH", latest_edition: nil)
    membership = @group.memberships.build(document:)

    @collection.save && @group.save && membership.save
    links = document_collection_group_member_links(@collection, @group, membership)

    assert_no_match "View", links
    assert_match confirm_destroy_admin_document_collection_group_document_collection_group_membership_path(@collection, @group, membership), links
  end

  test "#unavailable_document_count should return the number of documents without editions" do
    document = build(:document, slug: "DOC PATH", latest_edition: nil)
    @group.memberships.build(document:)
    @group.memberships.build(document:)
    assert_equal 2, unavailable_document_count(@group.memberships)
  end

  test "#unavailable_document_count should return 0 if there are documents with editions" do
    edition = build(:edition, title: "DOC TITLE")
    document = build(:document, slug: "DOC PATH", latest_edition: edition)
    @group.memberships.build(document:)
    assert_equal 0, unavailable_document_count(@group.memberships)
  end

  test "#unavailable_document_count should not count non_whitehall_links" do
    non_whitehall_link = build(
      :document_collection_non_whitehall_link,
      base_path: "GOVUK PATH",
      title: "GOVUK TITLE",
    )
    @group.memberships.build(non_whitehall_link:)
    assert_equal 0, unavailable_document_count(@group.memberships)
  end
end
