require 'test_helper'

class Admin::DocumentsControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test 'is an admin controller' do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test 'should distinguish between document types when viewing the list of draft documents' do
    policy = create(:draft_policy)
    publication = create(:draft_publication)
    get :index

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test 'should distinguish between document types when viewing the list of submitted documents' do
    policy = create(:submitted_policy)
    publication = create(:submitted_publication)
    get :submitted

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test 'should distinguish between document types when viewing the list of published documents' do
    policy = create(:published_policy)
    publication = create(:published_publication)
    get :published

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test 'viewing the list of submitted policies should not show draft policies' do
    draft_document = create(:draft_policy)
    get :submitted

    refute assigns(:documents).include?(draft_document)
  end

  test 'viewing the list of published policies should only show published policies' do
    published_documents = [create(:published_policy)]
    get :published

    assert_equal published_documents, assigns(:documents)
  end

  test 'submitting should set submitted on the document' do
    draft_document = create(:draft_policy)
    post :submit, id: draft_document

    assert draft_document.reload.submitted?
  end

  test 'submitting should redirect back to show page' do
    draft_document = create(:draft_policy)
    post :submit, id: draft_document

    assert_redirected_to admin_policy_path(draft_document)
    assert_equal "Your document has been submitted for review by a second pair of eyes", flash[:notice]
  end

  test 'publishing should redirect back to published documents' do
    submitted_document = create(:submitted_policy)
    login_as "Eddie", departmental_editor: true
    post :publish, id: submitted_document, document: {lock_version: submitted_document.lock_version}

    assert_redirected_to published_admin_documents_path
    assert_equal "The document #{submitted_document.title} has been published", flash[:notice]
  end

  test 'publishing should remove it from the set of submitted policies' do
    document_to_publish = create(:submitted_policy)
    login_as "Eddie", departmental_editor: true
    post :publish, id: document_to_publish, document: {lock_version: document_to_publish.lock_version}

    get :submitted
    refute assigns(:documents).include?(document_to_publish)
  end

  test 'failing to publish an document should set a flash' do
    document_to_publish = create(:submitted_policy)
    login_as "Willy Writer", departmental_editor: false
    post :publish, id: document_to_publish, document: {lock_version: document_to_publish.lock_version}

    assert_equal "Only departmental editors can publish policies", flash[:alert]
  end

  test 'failing to publish an document should redirect back to the document' do
    document_to_publish = create(:submitted_policy)
    login_as "Willy Writer", departmental_editor: false
    post :publish, id: document_to_publish, document: {lock_version: document_to_publish.lock_version}

    assert_redirected_to admin_policy_path(document_to_publish)
  end

  test 'failing to publish a stale document should redirect back to the document' do
    policy_to_publish = create(:submitted_policy)
    lock_version = policy_to_publish.lock_version
    policy_to_publish.update_attributes!(title: "new title")
    login_as "Eddie", departmental_editor: true
    post :publish, id: policy_to_publish, document: {lock_version: lock_version}

    assert_redirected_to admin_policy_path(policy_to_publish)
    assert_equal "This document has been edited since you viewed it; you are now viewing the latest version", flash[:alert]
  end

  test "revising the published document should create a new draft document" do
    published_document = create(:published_policy)
    Document.stubs(:find).returns(published_document)
    draft_document = create(:draft_policy)
    published_document.expects(:create_draft).with(@user).returns(draft_document)
    draft_document.expects(:valid?).returns(true)

    post :revise, id: published_document
  end

  test "revising a published document redirects to edit for the new draft" do
    published_document = create(:published_policy)

    post :revise, id: published_document

    draft_document = Document.last
    assert_redirected_to edit_admin_policy_path(draft_document.reload)
  end

  test "failing to revise an document should redirect to the existing draft" do
    published_document = create(:published_policy)
    existing_draft = create(:draft_policy, document_identity: published_document.document_identity)

    post :revise, id: published_document

    assert_redirected_to edit_admin_policy_path(existing_draft)
    assert_equal "There is already an active draft for this document", flash[:alert]
  end
end
