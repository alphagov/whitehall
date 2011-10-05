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
    edition = build(:edition, document: nil)
    refute edition.valid?
  end

  test 'should be invalid if policy has existing unpublished editions' do
    policy = create(:policy)
    existing_edition = create(:draft_edition, document: policy)
    edition = build(:edition, document: policy)
    refute edition.valid?
  end

  test 'should be invalid when published if policy has existing published editions' do
    policy = create(:policy)
    existing_edition = create(:published_edition, document: policy)
    edition = build(:published_edition, document: policy)
    refute edition.valid?
  end

  test 'should only return unsubmitted draft policies' do
    draft_edition = create(:draft_edition)
    submitted_edition = create(:submitted_edition)
    assert_equal [draft_edition], Edition.unsubmitted
  end

  test 'should only return the submitted policies' do
    draft_edition = create(:draft_edition)
    submitted_edition = create(:submitted_edition)
    assert_equal [submitted_edition], Edition.submitted
  end

  test 'should be editable if a draft' do
    draft_edition = create(:draft_edition)
    assert draft_edition.editable_by?(create(:policy_writer))
  end

  test 'should not be editable if published' do
    published_edition = create(:published_edition)
    refute published_edition.editable_by?(create(:policy_writer))
  end

  test 'should not be editable if archived' do
    archived_edition = create(:archived_edition)
    refute archived_edition.editable_by?(create(:policy_writer))
  end

  test 'should be submittable if draft and not submitted' do
    draft_edition = create(:draft_edition)
    assert draft_edition.submittable_by?(create(:policy_writer))
  end

  test 'not be submittable if submitted' do
    submitted_edition = create(:submitted_edition)
    refute submitted_edition.submittable_by?(create(:policy_writer))
  end

  test 'not be submittable if published' do
    published_edition = create(:published_edition)
    refute published_edition.submittable_by?(create(:policy_writer))
  end

  test 'not be archived if archived' do
    archived_edition = create(:archived_edition)
    refute archived_edition.submittable_by?(create(:policy_writer))
  end

  test 'should not be publishable when not submitted' do
    edition = create(:draft_edition)
    refute edition.publishable_by?(create(:departmental_editor))
  end

  test 'should fail publication when not submitted' do
    edition = create(:draft_edition)
    edition.publish_as!(create(:departmental_editor))
    refute edition.published?
  end

  test 'should not be publishable when already published' do
    edition = create(:published_edition)
    refute edition.publishable_by?(create(:departmental_editor))
  end

  test 'should fail publication when already published' do
    edition = create(:published_edition)
    refute edition.publish_as!(create(:departmental_editor))
    assert_equal ["This edition has already been published"], edition.errors.full_messages
  end

  test 'should not be publishable by the original author' do
    author = create(:departmental_editor)
    edition = create(:submitted_edition, author: author)
    refute edition.publishable_by?(author)
  end

  test 'should fail publication by the author' do
    author = create(:departmental_editor)
    edition = create(:submitted_edition, author: author)
    refute edition.publish_as!(author)
    refute edition.published?
    assert_equal ["You are not the second set of eyes"], edition.errors.full_messages
  end

  test 'should be publishable by departmental editors' do
    edition = create(:submitted_edition)
    departmental_editor = create(:departmental_editor)
    assert edition.publishable_by?(departmental_editor)
  end

  test 'should succeed publication when published by departmental editors' do
    author = create(:policy_writer)
    edition = create(:submitted_edition, author: author)
    other_user = create(:departmental_editor)
    assert edition.publish_as!(other_user)
    assert edition.published?
  end

  test 'should not return published policies in submitted' do
    edition = create(:submitted_edition)
    edition.publish_as!(create(:departmental_editor))
    refute Edition.submitted.include?(edition)
  end

  test 'should fail publication by normal users' do
    edition = create(:submitted_edition)
    refute edition.publish_as!(create(:policy_writer))
    refute edition.published?
    assert_equal ["Only departmental editors can publish policies"], edition.errors.full_messages
  end

  test 'should fail publication if lock version is not current' do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition, title: "old title")

    other_instance = Edition.find(edition.id)
    other_instance.update_attributes(title: "new title")

    assert_raises(ActiveRecord::StaleObjectError) do
      refute edition.publish_as!(editor, edition.lock_version)
    end
    refute Edition.find(edition.id).published?
  end

  test 'should archive earlier editions on publication' do
    published_edition = create(:published_edition)
    author = create(:policy_writer)
    edition = create(:submitted_edition, document: published_edition.document, author: author)
    editor = create(:departmental_editor)
    edition.publish_as!(editor)

    published_edition.reload
    assert published_edition.archived?
  end

  test 'should not be publishable when archived' do
    edition = create(:archived_edition)
    refute edition.publishable_by?(create(:departmental_editor))
  end

  test 'should build a draft copy of the existing edition with the supplied author' do
    attachment = create(:attachment)
    published_edition = create(:published_edition, attachment: attachment, submitted: true)
    new_author = create(:policy_writer)
    draft_edition = published_edition.build_draft(new_author)

    assert draft_edition.new_record?
    refute draft_edition.published?
    refute draft_edition.submitted?
    assert_equal new_author, draft_edition.author
    assert_equal published_edition.attachment, draft_edition.attachment
    assert_equal published_edition.title, draft_edition.title
    assert_equal published_edition.body, draft_edition.body
  end

  test 'when initially created' do
    edition = create(:edition)
    assert edition.draft?
    refute edition.submitted?
    refute edition.published?
  end

  test 'when submitted' do
    edition = create(:submitted_edition)
    assert edition.draft?
    assert edition.submitted?
    refute edition.published?
  end

  test 'when published' do
    edition = create(:submitted_edition)
    edition.publish_as!(create(:departmental_editor))
    refute edition.draft?
    assert edition.published?
  end

  test 'setting topic_ids assigns associated topics' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    edition = create(:draft_edition, topics: [first_topic])
    edition.topic_ids = [first_topic.id, second_topic.id]
    assert_equal [first_topic, second_topic], edition.topics
  end
end