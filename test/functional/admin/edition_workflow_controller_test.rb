require 'test_helper'

class Admin::EditionWorkflowControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  test 'publishing should redirect back to published editions' do
    submitted_edition = create(:submitted_policy)
    login_as :departmental_editor
    post :publish, id: submitted_edition, document: {lock_version: submitted_edition.lock_version}

    assert_redirected_to admin_documents_path(state: :published)
    assert_equal "The document #{submitted_edition.title} has been published", flash[:notice]
  end

  test 'publishing should remove it from the set of submitted policies' do
    edition_to_publish = create(:submitted_policy)
    login_as :departmental_editor
    post :publish, id: edition_to_publish, document: {lock_version: edition_to_publish.lock_version}

    refute Edition.submitted.include?(edition_to_publish)
  end

  test 'publishing should not mark the edition as force published' do
    edition_to_publish = create(:submitted_policy)
    login_as :departmental_editor
    post :publish, id: edition_to_publish, document: {lock_version: edition_to_publish.lock_version}

    refute edition_to_publish.reload.force_published?
  end

  test 'failing to publish an edition should set a flash' do
    edition_to_publish = create(:submitted_policy)
    login_as :policy_writer
    post :publish, id: edition_to_publish, document: {lock_version: edition_to_publish.lock_version}

    assert_equal "Only departmental editors can publish", flash[:alert]
  end

  test 'failing to publish an edition should redirect back to the edition' do
    edition_to_publish = create(:submitted_policy)
    login_as :policy_writer
    post :publish, id: edition_to_publish, document: {lock_version: edition_to_publish.lock_version}

    assert_redirected_to admin_policy_path(edition_to_publish)
  end

  test 'failing to publish a stale edition should redirect back to the edition' do
    policy_to_publish = create(:submitted_policy)
    lock_version = policy_to_publish.lock_version
    policy_to_publish.update_attributes!(title: "new title")
    login_as :departmental_editor
    post :publish, id: policy_to_publish, document: {lock_version: lock_version}

    assert_redirected_to admin_policy_path(policy_to_publish)
    assert_equal "This document has been edited since you viewed it; you are now viewing the latest version", flash[:alert]
  end

  test 'force publishing should succeed where normal publishing would fail' do
    submitted_edition = create(:draft_policy)
    login_as :departmental_editor
    post :publish, id: submitted_edition, document: {lock_version: submitted_edition.lock_version}, force: true

    assert_redirected_to admin_documents_path(state: :published)
    assert_equal "The document #{submitted_edition.title} has been published", flash[:notice]
  end

  test 'force publishing should mark the edition as force published' do
    submitted_edition = create(:draft_policy)
    login_as :departmental_editor
    post :publish, id: submitted_edition, document: {lock_version: submitted_edition.lock_version}, force: true

    assert submitted_edition.reload.force_published?
  end

  test 'should set change note on edition if one is provided' do
    edition = create(:submitted_policy)
    login_as :departmental_editor
    post :publish, id: edition, document: {
      change_note: "change-note",
      lock_version: edition.lock_version
    }

    assert_equal "change-note", edition.reload.change_note
  end

  test 'should record minor change on a edition' do
    edition = create(:submitted_policy)
    login_as :departmental_editor
    post :publish, id: edition, document: {
      minor_change: true,
      lock_version: edition.lock_version
    }

    assert_equal true, edition.reload.minor_change
  end

  test 'submitting should set submitted on the edition' do
    login_as :policy_writer

    draft_edition = create(:draft_policy)
    post :submit, id: draft_edition

    assert draft_edition.reload.submitted?
  end

  test 'submitting should redirect back to show page' do
    login_as :policy_writer

    draft_edition = create(:draft_policy)
    post :submit, id: draft_edition

    assert_redirected_to admin_policy_path(draft_edition)
    assert_equal "Your document has been submitted for review by a second pair of eyes", flash[:notice]
  end

  test "rejecting the document should mark it as rejected" do
    login_as :departmental_editor

    submitted_document = create(:submitted_policy)

    post :reject, id: submitted_document

    assert submitted_document.reload.rejected?
  end

  test "rejecting the document should redirect to create a new editorial remark to explain why" do
    login_as :departmental_editor

    submitted_document = create(:submitted_policy)

    post :reject, id: submitted_document
    assert_redirected_to new_admin_document_editorial_remark_path(submitted_document)
  end
end