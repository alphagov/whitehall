require "test_helper"

class Edition::IdentifiableTest < ActiveSupport::TestCase
  test "should set document type on document before validation for use in slug duplicate detection" do
    policy = build(:policy)
    policy.valid?
    assert_equal "Policy", policy.document.document_type
  end

  test "should not attempt to set document type if document is not present" do
    policy = build(:policy)
    policy.stubs(:document).returns(nil)
    assert_nothing_raised(NoMethodError) { policy.valid? }
  end

  test "should not allow the same slug to be used again for the same document type" do
    same_title = "same-title"
    policy_1 = create(:policy, title: same_title)
    policy_2 = create(:policy, title: same_title)

    refute_equal policy_1.document.slug, policy_2.document.slug
  end

  test "should allow the same slug to be used again for another document type" do
    same_title = "same-title"
    policy = create(:policy, title: same_title)
    publication = create(:publication, title: same_title)

    assert_equal policy.document.slug, publication.document.slug
  end

  test "should allow the same slug to be used for a news article and a speech" do
    same_title = "same-title"
    policy = create(:news_article, title: same_title)
    publication = create(:speech, title: same_title)

    assert_equal policy.document.slug, publication.document.slug
  end

  test "should return the edition of the correct type when matching slugs for other types exist" do
    same_title = "same-title"
    policy = create(:published_policy, title: same_title)
    publication = create(:published_publication, title: same_title)

    assert_equal policy, Policy.published_as(same_title)
    assert_equal publication, Publication.published_as(same_title)
  end

  test "should be linkable when draft if document is published" do
    policy = create(:published_policy)
    new_edition = policy.create_draft(create(:policy_writer))
    assert new_edition.linkable?
  end

  test "should not be linkable if document is not published" do
    policy = create(:draft_policy)
    refute policy.linkable?
  end

  test "should be linkable when archived if document is published" do
    policy = create(:published_policy)
    new_edition = policy.create_draft(create(:policy_writer))
    new_edition.publish_as(create(:departmental_editor), force: true)
    assert policy.linkable?
  end

  test "published editions with drafts waiting should be previewable" do
    policy = create(:published_policy)
    new_edition = policy.create_draft(create(:policy_writer))
    assert policy.previewable?
  end

  test "published editions shouldn't be previewable" do
    policy = create(:published_policy)
    refute policy.previewable?
  end

  test "slug of an associated draft policy doesn't increment unexpectedly" do
    policy1 = create(:draft_policy, title: "This is my policy")
    policy2 = create(:draft_policy, title: "This is my policy")
    policy1.body = "foo"
    policy1.save

    slug = policy2.document.slug
    policy2.save
    assert_equal slug, policy2.document.reload.slug
  end

  test "slug changes of draft if title changes" do
    policy = create(:draft_policy, title: "This is my policy")
    old_slug = policy.document.slug
    policy.title = "Another thing"
    policy.save

    refute_equal old_slug, policy.document.reload.slug
  end
end
