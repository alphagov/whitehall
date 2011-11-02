require "test_helper"

class Document::PublishingTest < ActiveSupport::TestCase
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

  test "should fail publication by normal users" do
    document = create(:submitted_policy)
    refute document.publish_as(create(:policy_writer))
    refute document.published?
    assert_equal ["Only departmental editors can publish"], document.errors.full_messages
  end

  test "should fail publication if lock version is not current" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy, title: "old title")

    other_instance = Document.find(document.id)
    other_instance.update_attributes(title: "new title")

    assert_raises(ActiveRecord::StaleObjectError) do
      refute document.publish_as(editor)
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
end