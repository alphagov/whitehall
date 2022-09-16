require "test_helper"

class DocumentSeriesGroupTest < ActiveSupport::TestCase
  test "new groups should set #ordering when assigned to a series" do
    series = create(:document_collection)
    series.groups << build(:document_collection_group)

    assert_equal [1, 2], series.groups.reload.map(&:ordering)
  end

  test "#set_membership_ids_in_order! should associate documents and set their\
        membership's ordering to the position of the membership id in the passed in array" do
    group = build(:document_collection_group)

    membership1 = create(:document_collection_group_membership)
    membership2 = create(:document_collection_group_membership)
    membership3 = create(:document_collection_group_membership)

    group.memberships << membership1
    group.memberships << membership2
    group.memberships << membership3

    group.set_membership_ids_in_order! [membership3.id, membership1.id]

    assert group.memberships.include? membership1
    assert group.memberships.include? membership3
    assert_not group.memberships.include? membership2

    assert_equal 0, group.memberships.find(membership3.id).ordering
    assert_equal 1, group.memberships.find(membership1.id).ordering
  end

  test "#dup should also clone document memberships" do
    group = create(
      :document_collection_group,
      documents: [
        build(:document),
        build(:document),
        build(:document),
      ],
    )

    group.memberships[0].ordering = 2
    group.memberships[1].ordering = 1
    group.memberships[2].ordering = 3

    new_group = group.dup

    assert_not_equal group.memberships[0],          new_group.memberships[0]
    assert_equal     group.memberships[0].document, new_group.memberships[0].document
    assert_equal     1,                             new_group.memberships[1].ordering
    assert_equal     3,                             new_group.memberships[2].ordering
  end

  test "#slug generates slugs of the heading" do
    group = create(:document_collection_group, heading: "Foo bar")
    assert_equal group.slug, "foo-bar"
  end

  test "#content_ids contain document and non-whitehall links in order" do
    document = build(:document)
    non_whitehall_link = build(:document_collection_non_whitehall_link)
    group = create(
      :document_collection_group,
      memberships: [
        build(:document_collection_group_membership, document:),
        build(
          :document_collection_group_membership,
          document: nil,
          non_whitehall_link:,
        ),
      ],
    )

    group.memberships[0].update!(ordering: 2)
    group.memberships[1].update!(ordering: 1)
    group.reload

    assert_equal group.content_ids, [non_whitehall_link.content_id, document.content_id]
  end
end
