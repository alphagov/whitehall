require "test_helper"

class DocumentCollectionGroupMembershipTest < ActiveSupport::TestCase
  test "maintain ordering of documents in a group" do
    group = create(:document_collection_group, document_collection: build(:document_collection))
    documents = [build(:document), build(:document)]
    group.documents = documents
    assert_equal [0, 1], group.memberships.reload.map(&:ordering)
  end

  test "it uses the ordering of the membership to set ordering" do
    membership = build(:document_collection_group_membership)
    group = create(:document_collection_group)
    group.memberships = [
      build(:document_collection_group_membership),
      build(:document_collection_group_membership),
      build(:document_collection_group_membership),
      membership,
    ]

    membership.save!
    assert_equal 0, membership.reload.ordering
  end

  test "it is given an automatic ordering at the top of the group, pushing existing memberships down" do
    group = create(
      :document_collection_group,
      memberships: [
        build(:document_collection_group_membership),
        build(:document_collection_group_membership),
      ],
    )
    existing_memberships = group.memberships.reload.to_a

    membership = create(
      :document_collection_group_membership,
      document_collection_group: group,
    )

    assert_equal 0, membership.ordering
    assert_equal [1, 2], existing_memberships.map { |m| m.reload.ordering }.sort
    assert_equal membership, group.memberships.reload.first
  end

  test "it adapts the auto ordering if the last item has a weird ordering" do
    weird_membership = build(:document_collection_group_membership)
    group = create(:document_collection_group, memberships: [weird_membership])
    weird_membership.update!(ordering: 6)

    membership = create(
      :document_collection_group_membership,
      document_collection_group: group,
    )
    assert_equal 0, membership.ordering
    assert_equal 7, weird_membership.reload.ordering
  end

  test "is invalid without a document or a non-whitehall link" do
    assert_not build(:document_collection_group_membership, document: nil, non_whitehall_link: nil).valid?
  end

  test "is invalid with both a document and a external link" do
    assert_not build(
      :document_collection_group_membership,
      document: build(:document),
      non_whitehall_link: build(:document_collection_non_whitehall_link),
    ).valid?
  end

  test "is invalid without a document_collection_group" do
    assert_not build(:document_collection_group_membership, document_collection_group: nil).valid?
  end
end
