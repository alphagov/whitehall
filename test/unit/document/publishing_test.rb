require "test_helper"

class Document::PublishingTest < ActiveSupport::TestCase
  test "is publishable by an editor when submitted" do
    document = create(:submitted_policy)
    assert document.publishable_by?(create(:departmental_editor))
  end

  test "is never publishable by a writer" do
    writer = create(:policy_writer)
    document = create(:submitted_policy)
    refute document.publishable_by?(writer)
    refute document.force_publishable_by?(writer)
    assert_equal "Only departmental editors can publish", document.reason_to_prevent_publication_by(writer)
  end

  test "is never publishable when already published" do
    editor = create(:departmental_editor)
    document = create(:published_policy)
    refute document.publishable_by?(editor)
    refute document.force_publishable_by?(editor)
    assert_equal "This edition has already been published", document.reason_to_prevent_publication_by(editor)
  end

  test "is not normally publishable when draft" do
    editor = create(:departmental_editor)
    document = create(:draft_policy)
    refute document.publishable_by?(editor)
    assert_equal "Not ready for publication", document.reason_to_prevent_publication_by(editor)
  end

  test "is force publishable when draft" do
    document = create(:draft_policy)
    assert document.force_publishable_by?(create(:departmental_editor))
  end

  test "is not normally publishable by the original author" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy, author: editor)
    refute document.publishable_by?(editor)
    assert_equal "You are not the second set of eyes", document.reason_to_prevent_publication_by(editor)
  end

  test "is force publishable by the original author" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy, author: editor)
    assert document.force_publishable_by?(editor)
  end

  test "is never publishable when rejected" do
    editor = create(:departmental_editor)
    document = create(:rejected_document)
    refute document.publishable_by?(editor)
    refute document.force_publishable_by?(editor)
    assert_equal "This edition has been rejected", document.reason_to_prevent_publication_by(editor)
  end

  test "is never publishable when archived" do
    editor = create(:departmental_editor)
    document = create(:archived_policy)
    refute document.publishable_by?(editor)
    refute document.force_publishable_by?(editor)
    assert_equal "This edition has been archived", document.reason_to_prevent_publication_by(editor)
  end

  test "is never publishable when deleted" do
    editor = create(:departmental_editor)
    document = create(:deleted_policy)
    refute document.publishable_by?(editor)
    refute document.force_publishable_by?(editor)
    assert_equal "This edition has been deleted", document.reason_to_prevent_publication_by(editor)
  end

  test "publication marks document as published" do
    document = create(:submitted_policy)
    document.publish_as(create(:departmental_editor))
    assert document.reload.published?
  end

  test "publication records time of publication" do
    document = create(:submitted_policy)
    document.publish_as(create(:departmental_editor))
    assert_equal Time.now, document.reload.published_at
  end

  test "publication archives previous published versions" do
    published_policy = create(:published_policy)
    document = create(:submitted_policy, document_identity: published_policy.document_identity)
    document.publish_as(create(:departmental_editor))
    assert published_policy.reload.archived?
  end

  test "publication fails if not publishable by user" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy)
    document.stubs(:publishable_by?).with(editor).returns(false)
    refute document.publish_as(editor)
    refute document.reload.published?
  end

  test "publication adds reason for failure to validation errors" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy)
    document.stubs(:publishable_by?).returns(false)
    document.stubs(:reason_to_prevent_publication_by).with(editor, {}).returns('a spurious reason')
    document.publish_as(editor)
    assert_equal ['a spurious reason'], document.errors.full_messages
  end

  test "publication raises StaleObjectError if lock version is not current" do
    document = create(:submitted_policy, title: "old title")

    Document.find(document.id).update_attributes(title: "new title")

    assert_raises(ActiveRecord::StaleObjectError) do
      document.publish_as(create(:departmental_editor))
    end
    refute Document.find(document.id).published?
  end
end