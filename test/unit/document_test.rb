require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    document = build(:document)
    assert document.valid?
  end

  test "should be invalid without a title" do
    document = build(:document, title: nil)
    refute document.valid?
  end

  test "should be invalid without a body" do
    document = build(:document, body: nil)
    refute document.valid?
  end

  test "should be invalid without an author" do
    document = build(:document, author: nil)
    refute document.valid?
  end

  test "should be invalid without a document" do
    document = build(:document, document_identity: nil)
    refute document.valid?
  end

  test "should be invalid if policy has existing unpublished documents" do
    policy = create(:draft_policy)
    document = build(:document, document_identity: policy.document_identity)
    refute document.valid?
  end

  test "should be invalid when published if policy has existing published documents" do
    policy = create(:published_policy)
    document = build(:published_policy, document_identity: policy.document_identity)
    refute document.valid?
  end

  test "should be findable through public identity if published" do
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy, document_identity: published_policy.document_identity)
    assert_equal published_policy, Document.published_as(published_policy.document_identity.id)
  end

  test "should not be findable through public identity if not" do
    draft_policy = create(:draft_policy)
    assert_nil Document.published_as(draft_policy.document_identity.id)
  end

  test "should only return unsubmitted draft policies" do
    draft_policy = create(:draft_policy)
    submitted_policy = create(:submitted_policy)
    assert_equal [draft_policy], Document.unsubmitted
  end

  test "should only return the submitted policies" do
    draft_policy = create(:draft_policy)
    submitted_policy = create(:submitted_policy)
    assert_equal [submitted_policy], Document.submitted
  end

  test "should be editable if a draft" do
    draft_policy = create(:draft_policy)
    assert draft_policy.editable_by?(create(:policy_writer))
  end

  test "should not be editable if published" do
    published_policy = create(:published_policy)
    refute published_policy.editable_by?(create(:policy_writer))
  end

  test "should not be editable if archived" do
    archived_policy = create(:archived_policy)
    refute archived_policy.editable_by?(create(:policy_writer))
  end

  test "should be submittable if draft and not submitted" do
    draft_policy = create(:draft_policy)
    assert draft_policy.submittable_by?(create(:policy_writer))
  end

  test "not be submittable if submitted" do
    submitted_policy = create(:submitted_policy)
    refute submitted_policy.submittable_by?(create(:policy_writer))
  end

  test "not be submittable if published" do
    published_policy = create(:published_policy)
    refute published_policy.submittable_by?(create(:policy_writer))
  end

  test "not be archived if archived" do
    archived_policy = create(:archived_policy)
    refute archived_policy.submittable_by?(create(:policy_writer))
  end

  test "should not be publishable when not submitted" do
    document = create(:draft_policy)
    refute document.publishable_by?(create(:departmental_editor))
  end

  test "should fail publication when not submitted" do
    document = create(:draft_policy)
    document.publish_as(create(:departmental_editor))
    refute document.published?
  end

  test "should not be publishable when already published" do
    document = create(:published_policy)
    refute document.publishable_by?(create(:departmental_editor))
  end

  test "should fail publication when already published" do
    document = create(:published_policy)
    refute document.publish_as(create(:departmental_editor))
    assert_equal ["This edition has already been published"], document.errors.full_messages
  end

  test "should not be publishable by the original author" do
    author = create(:departmental_editor)
    document = create(:submitted_policy, author: author)
    refute document.publishable_by?(author)
  end

  test "should fail publication by the author" do
    author = create(:departmental_editor)
    document = create(:submitted_policy, author: author)
    refute document.publish_as(author)
    refute document.published?
    assert_equal ["You are not the second set of eyes"], document.errors.full_messages
  end

  test "should be publishable by departmental editors" do
    document = create(:submitted_policy)
    departmental_editor = create(:departmental_editor)
    assert document.publishable_by?(departmental_editor)
  end

  test "should succeed publication when published by departmental editors" do
    author = create(:policy_writer)
    document = create(:submitted_policy, author: author)
    other_user = create(:departmental_editor)
    assert document.publish_as(other_user)
    assert document.published?
  end

  test "should not return published policies in submitted" do
    document = create(:submitted_policy)
    document.publish_as(create(:departmental_editor))
    refute Document.submitted.include?(document)
  end

  test "should fail publication by normal users" do
    document = create(:submitted_policy)
    refute document.publish_as(create(:policy_writer))
    refute document.published?
    assert_equal ["Only departmental editors can publish policies"], document.errors.full_messages
  end

  test "should fail publication if lock version is not current" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy, title: "old title")

    other_instance = Document.find(document.id)
    other_instance.update_attributes(title: "new title")

    assert_raises(ActiveRecord::StaleObjectError) do
      refute document.publish_as(editor, document.lock_version)
    end
    refute Document.find(document.id).published?
  end

  test "should archive earlier documents on publication" do
    published_policy = create(:published_policy)
    author = create(:policy_writer)
    document = create(:submitted_policy, document_identity: published_policy.document_identity, author: author)
    editor = create(:departmental_editor)
    document.publish_as(editor)

    published_policy.reload
    assert published_policy.archived?
  end

  test "should not be publishable when archived" do
    document = create(:archived_policy)
    refute document.publishable_by?(create(:departmental_editor))
  end

  test "should build a draft copy of the existing document with the supplied author" do
    published_policy = create(:published_policy)
    new_author = create(:policy_writer)
    draft_policy = published_policy.build_draft(new_author)

    assert draft_policy.new_record?
    refute draft_policy.published?
    refute draft_policy.submitted?
    assert_equal new_author, draft_policy.author
    assert_equal published_policy.title, draft_policy.title
    assert_equal published_policy.body, draft_policy.body
  end

  test "should build a draft copy with references to topics, organisations & ministerial roles" do
    topic = create(:topic)
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role)

    published_policy = create(:published_policy, topics: [topic], organisations: [organisation], ministerial_roles: [ministerial_role])

    draft_policy = published_policy.build_draft(create(:policy_writer))

    assert_equal [topic], draft_policy.topics
    assert_equal [organisation], draft_policy.organisations
    assert_equal [ministerial_role], draft_policy.ministerial_roles
  end

  test "should build a draft copy with copies of supporting documents" do
    published_policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: published_policy)
    draft_policy = published_policy.build_draft(create(:policy_writer))

    assert new_supporting_document = draft_policy.supporting_documents.last
    refute_equal supporting_document, new_supporting_document
    assert_nil new_supporting_document.document
    assert_equal supporting_document.title, new_supporting_document.title
    assert_equal supporting_document.body, new_supporting_document.body
  end

  test "when initially created" do
    document = create(:document)
    assert document.draft?
    refute document.submitted?
    refute document.published?
  end

  test "when submitted" do
    document = create(:submitted_policy)
    assert document.draft?
    assert document.submitted?
    refute document.published?
  end

  test "when published" do
    document = create(:submitted_policy)
    document.publish_as(create(:departmental_editor))
    refute document.draft?
    assert document.published?
  end

  test "is findable by document identity when published" do
    document = create(:published_policy)
    assert_equal document, Document.published_as(document.document_identity.to_param)
  end

  test "is not findable by document identity when not published" do
    document = create(:submitted_policy)
    assert_nil Document.published_as(document.document_identity.to_param)
  end

  test "returns nil if found by unknown document identity" do
    assert_nil Document.published_as('unknown')
  end
end