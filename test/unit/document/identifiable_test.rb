require "test_helper"

class Document::IdentifiableTest < ActiveSupport::TestCase
  test "should set document type on document identity before validation for use in slug duplicate detection" do
    policy = build(:policy)
    policy.valid?
    assert_equal "Policy", policy.document_identity.document_type
  end

  test "should not attempt to set document type if document identity is not present" do
    policy = build(:policy)
    policy.stubs(:document_identity).returns(nil)
    assert_nothing_raised(NoMethodError) { policy.valid? }
  end

  test "should not allow the same slug to be used again for the same document type" do
    same_title = "same-title"
    policy_1 = create(:policy, title: same_title)
    policy_2 = create(:policy, title: same_title)

    refute_equal policy_1.document_identity.slug, policy_2.document_identity.slug
  end

  test "should allow the same slug to be used again for another document type" do
    same_title = "same-title"
    policy = create(:policy, title: same_title)
    publication = create(:publication, title: same_title)

    assert_equal policy.document_identity.slug, publication.document_identity.slug
  end

  test "should return the document of the correct type when matching slugs for other types exist" do
    same_title = "same-title"
    policy = create(:published_policy, title: same_title)
    publication = create(:published_publication, title: same_title)

    assert_equal policy, Policy.published_as(same_title)
    assert_equal publication, Publication.published_as(same_title)
  end

  test "should be linkable when draft if document identity is published" do
    policy = create(:published_policy)
    new_edition = policy.create_draft(create(:policy_writer))
    assert new_edition.linkable?
  end

  test "should not be linkable if document identity is not published" do
    policy = create(:draft_policy)
    refute policy.linkable?
  end

  test "should be linkable when archived if document identity is published" do
    policy = create(:published_policy)
    new_edition = policy.create_draft(create(:policy_writer))
    new_edition.publish_as(create(:departmental_editor), force: true)
    assert policy.linkable?
  end
end