require 'test_helper'

class Admin::DocumentPublishingControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  test 'publishing should redirect back to published documents' do
    submitted_document = create(:submitted_policy)
    login_as :departmental_editor
    post :create, document_id: submitted_document, document: {lock_version: submitted_document.lock_version}

    assert_redirected_to admin_documents_path(state: :published)
    assert_equal "The document #{submitted_document.title} has been published", flash[:notice]
  end

  test 'publishing should remove it from the set of submitted policies' do
    document_to_publish = create(:submitted_policy)
    login_as :departmental_editor
    post :create, document_id: document_to_publish, document: {lock_version: document_to_publish.lock_version}

    refute Edition.submitted.include?(document_to_publish)
  end

  test 'publishing should not mark the document as force published' do
    document_to_publish = create(:submitted_policy)
    login_as :departmental_editor
    post :create, document_id: document_to_publish, document: {lock_version: document_to_publish.lock_version}

    refute document_to_publish.reload.force_published?
  end

  test 'failing to publish an document should set a flash' do
    document_to_publish = create(:submitted_policy)
    login_as :policy_writer
    post :create, document_id: document_to_publish, document: {lock_version: document_to_publish.lock_version}

    assert_equal "Only departmental editors can publish", flash[:alert]
  end

  test 'failing to publish an document should redirect back to the document' do
    document_to_publish = create(:submitted_policy)
    login_as :policy_writer
    post :create, document_id: document_to_publish, document: {lock_version: document_to_publish.lock_version}

    assert_redirected_to admin_policy_path(document_to_publish)
  end

  test 'failing to publish a stale document should redirect back to the document' do
    policy_to_publish = create(:submitted_policy)
    lock_version = policy_to_publish.lock_version
    policy_to_publish.update_attributes!(title: "new title")
    login_as :departmental_editor
    post :create, document_id: policy_to_publish, document: {lock_version: lock_version}

    assert_redirected_to admin_policy_path(policy_to_publish)
    assert_equal "This document has been edited since you viewed it; you are now viewing the latest version", flash[:alert]
  end

  test 'force publishing should succeed where normal publishing would fail' do
    submitted_document = create(:draft_policy)
    login_as :departmental_editor
    post :create, document_id: submitted_document, document: {lock_version: submitted_document.lock_version}, force: true

    assert_redirected_to admin_documents_path(state: :published)
    assert_equal "The document #{submitted_document.title} has been published", flash[:notice]
  end

  test 'force publishing should mark the document as force published' do
    submitted_document = create(:draft_policy)
    login_as :departmental_editor
    post :create, document_id: submitted_document, document: {lock_version: submitted_document.lock_version}, force: true

    assert submitted_document.reload.force_published?
  end

  test 'should set change note on document if one is provided' do
    document = create(:submitted_policy)
    login_as :departmental_editor
    post :create, document_id: document, document: {
      change_note: "change-note",
      lock_version: document.lock_version
    }

    assert_equal "change-note", document.reload.change_note
  end

  test 'should record minor change on a document' do
    document = create(:submitted_policy)
    login_as :departmental_editor
    post :create, document_id: document, document: {
      minor_change: true,
      lock_version: document.lock_version
    }

    assert_equal true, document.reload.minor_change
  end

end