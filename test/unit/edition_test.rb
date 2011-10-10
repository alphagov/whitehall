require 'test_helper'

class EditionTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    edition = build(:edition)
    assert edition.valid?
  end

  test 'should be invalid without a title' do
    edition = build(:edition, title: nil)
    refute edition.valid?
  end

  test 'should be invalid without a body' do
    edition = build(:edition, body: nil)
    refute edition.valid?
  end

  test 'should be invalid without an author' do
    edition = build(:edition, author: nil)
    refute edition.valid?
  end

  test 'should be invalid without a document' do
    edition = build(:edition, document_identity: nil)
    refute edition.valid?
  end

  test 'should be invalid if policy has existing unpublished editions' do
    policy = create(:draft_policy)
    edition = build(:edition, document_identity: policy.document_identity)
    refute edition.valid?
  end

  test 'should be invalid when published if policy has existing published editions' do
    policy = create(:published_policy)
    edition = build(:published_policy, document_identity: policy.document_identity)
    refute edition.valid?
  end

  test 'should only return unsubmitted draft policies' do
    draft_policy = create(:draft_policy)
    submitted_policy = create(:submitted_policy)
    assert_equal [draft_policy], Edition.unsubmitted
  end

  test 'should only return the submitted policies' do
    draft_policy = create(:draft_policy)
    submitted_policy = create(:submitted_policy)
    assert_equal [submitted_policy], Edition.submitted
  end

  test 'should be editable if a draft' do
    draft_policy = create(:draft_policy)
    assert draft_policy.editable_by?(create(:policy_writer))
  end

  test 'should not be editable if published' do
    published_policy = create(:published_policy)
    refute published_policy.editable_by?(create(:policy_writer))
  end

  test 'should not be editable if archived' do
    archived_policy = create(:archived_policy)
    refute archived_policy.editable_by?(create(:policy_writer))
  end

  test 'should be submittable if draft and not submitted' do
    draft_policy = create(:draft_policy)
    assert draft_policy.submittable_by?(create(:policy_writer))
  end

  test 'not be submittable if submitted' do
    submitted_policy = create(:submitted_policy)
    refute submitted_policy.submittable_by?(create(:policy_writer))
  end

  test 'not be submittable if published' do
    published_policy = create(:published_policy)
    refute published_policy.submittable_by?(create(:policy_writer))
  end

  test 'not be archived if archived' do
    archived_policy = create(:archived_policy)
    refute archived_policy.submittable_by?(create(:policy_writer))
  end

  test 'should not be publishable when not submitted' do
    edition = create(:draft_policy)
    refute edition.publishable_by?(create(:departmental_editor))
  end

  test 'should fail publication when not submitted' do
    edition = create(:draft_policy)
    edition.publish_as!(create(:departmental_editor))
    refute edition.published?
  end

  test 'should not be publishable when already published' do
    edition = create(:published_policy)
    refute edition.publishable_by?(create(:departmental_editor))
  end

  test 'should fail publication when already published' do
    edition = create(:published_policy)
    refute edition.publish_as!(create(:departmental_editor))
    assert_equal ["This edition has already been published"], edition.errors.full_messages
  end

  test 'should not be publishable by the original author' do
    author = create(:departmental_editor)
    edition = create(:submitted_policy, author: author)
    refute edition.publishable_by?(author)
  end

  test 'should fail publication by the author' do
    author = create(:departmental_editor)
    edition = create(:submitted_policy, author: author)
    refute edition.publish_as!(author)
    refute edition.published?
    assert_equal ["You are not the second set of eyes"], edition.errors.full_messages
  end

  test 'should be publishable by departmental editors' do
    edition = create(:submitted_policy)
    departmental_editor = create(:departmental_editor)
    assert edition.publishable_by?(departmental_editor)
  end

  test 'should succeed publication when published by departmental editors' do
    author = create(:policy_writer)
    edition = create(:submitted_policy, author: author)
    other_user = create(:departmental_editor)
    assert edition.publish_as!(other_user)
    assert edition.published?
  end

  test 'should not return published policies in submitted' do
    edition = create(:submitted_policy)
    edition.publish_as!(create(:departmental_editor))
    refute Edition.submitted.include?(edition)
  end

  test 'should fail publication by normal users' do
    edition = create(:submitted_policy)
    refute edition.publish_as!(create(:policy_writer))
    refute edition.published?
    assert_equal ["Only departmental editors can publish policies"], edition.errors.full_messages
  end

  test 'should fail publication if lock version is not current' do
    editor = create(:departmental_editor)
    edition = create(:submitted_policy, title: "old title")

    other_instance = Edition.find(edition.id)
    other_instance.update_attributes(title: "new title")

    assert_raises(ActiveRecord::StaleObjectError) do
      refute edition.publish_as!(editor, edition.lock_version)
    end
    refute Edition.find(edition.id).published?
  end

  test 'should archive earlier editions on publication' do
    published_policy = create(:published_policy)
    author = create(:policy_writer)
    edition = create(:submitted_policy, document_identity: published_policy.document_identity, author: author)
    editor = create(:departmental_editor)
    edition.publish_as!(editor)

    published_policy.reload
    assert published_policy.archived?
  end

  test 'should not be publishable when archived' do
    edition = create(:archived_policy)
    refute edition.publishable_by?(create(:departmental_editor))
  end

  test 'should build a draft copy of the existing edition with the supplied author' do
    attachment = create(:attachment)
    topic = create(:topic)
    published_policy = create(:published_policy, attachment: attachment, submitted: true, topics: [topic])
    new_author = create(:policy_writer)
    draft_policy = published_policy.build_draft(new_author)

    assert draft_policy.new_record?
    refute draft_policy.published?
    refute draft_policy.submitted?
    assert_equal new_author, draft_policy.author
    assert_equal published_policy.attachment, draft_policy.attachment
    assert_equal published_policy.title, draft_policy.title
    assert_equal published_policy.body, draft_policy.body
    assert_equal published_policy.topics, draft_policy.topics
  end

  test 'when initially created' do
    edition = create(:edition)
    assert edition.draft?
    refute edition.submitted?
    refute edition.published?
  end

  test 'when submitted' do
    edition = create(:submitted_policy)
    assert edition.draft?
    assert edition.submitted?
    refute edition.published?
  end

  test 'when published' do
    edition = create(:submitted_policy)
    edition.publish_as!(create(:departmental_editor))
    refute edition.draft?
    assert edition.published?
  end
end