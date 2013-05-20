# encoding: utf-8

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

  test "should return nil if the edition isn't translated into the supplied locale" do
    policy = create(:published_policy, translated_into: 'fr')

    assert_nil Policy.published_as(policy.slug, 'zh')
  end

  test "should return the edition if it is translated into the supplied locale" do
    policy = create(:published_policy, translated_into: 'fr')

    assert_equal policy, Policy.published_as(policy.slug, 'fr')
  end

  test "should return the edition if it is translated into the default locale when none is specified" do
    policy = create(:published_policy, translated_into: I18n.default_locale)

    assert_equal policy, Policy.published_as(policy.slug)
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

  test "update slug if title changes on draft edition" do
    policy = create(:draft_policy, title: "This is my policy")
    policy.update_attributes!(title: "Another thing")

    assert_equal "another-thing", policy.document.reload.slug
  end

  test "do not update slug if non-english title changes on draft edition" do
    policy = create(:draft_policy, title: "This is my policy")
    with_locale(:es) do
      policy.update_attributes!(title: "Spanish thing", summary: "Avoid validation error", body: "Avoid validation error")
    end

    assert_equal "this-is-my-policy", policy.document.reload.slug
  end

  test "should not update the slug of an existing edition when saved in the presence of a new edition with the same title" do
    existing_edition = create(:draft_policy, title: "This is my policy")
    assert_equal 'this-is-my-policy', existing_edition.document.reload.slug

    new_edition_with_same_title = create(:draft_policy, title: "This is my policy")
    assert_equal 'this-is-my-policy--2', new_edition_with_same_title.document.reload.slug

    existing_edition.save!
    assert_equal 'this-is-my-policy', existing_edition.document.reload.slug
  end

  test "non-English editions get a slug based on the document id rather than the title" do
    edition = create(:world_location_news_article, title: 'Faire la fête', locale: 'fr')
    document = edition.document
    assert_equal document.id.to_s, document.slug
  end

  test "non-English editions do not get confused when documents exists with dodgy-nil-based slugs" do
    edition1 = create(:world_location_news_article, title: 'Faire la fête', locale: 'fr')
    edition1.document.update_attribute(:slug, '--1')

    edition2 = create(:world_location_news_article, title: 'Faire la fête', locale: 'fr')
    document = edition2.document
    assert_equal document.id.to_s, document.slug
  end
end
