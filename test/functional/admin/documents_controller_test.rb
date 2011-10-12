require 'test_helper'

class Admin::DocumentsControllerAuthenticationTest < ActionController::TestCase
  tests Admin::DocumentsController

  test 'guests should not be able to access index' do
    get :index

    assert_login_required
  end

  test 'guests should not be able to access published' do
    get :published

    assert_login_required
  end

  test 'guests should not be able to access submitted' do
    get :submitted

    assert_login_required
  end

  test 'guests should not be able to access new' do
    get :new

    assert_login_required
  end

  test 'guests should not be able to access create' do
    post :create, document: attributes_for(:document)

    assert_login_required
  end

  test 'guests should not be able to access edit' do
    document = create(:document)

    get :edit, id: document.to_param

    assert_login_required
  end

  test 'guests should not be able to access update' do
    document = create(:document)
    put :update, id: document.to_param, document: attributes_for(:document)

    assert_login_required
  end

  test 'guests should not be able to access publish' do
    document = create(:document)
    put :publish, id: document.to_param

    assert_login_required
  end

  test 'guests should not be able to access revise' do
    document = create(:document)
    post :revise, id: document.to_param

    assert_login_required
  end

  test 'guests should not be able to access show' do
    document = create(:document)
    get :show, id: document.to_param

    assert_login_required
  end
end

class Admin::DocumentsControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test 'new form should be for Policies if no document type given' do
    get :new

    assert_select "input[type='hidden'][name='document_type'][value='Policy']", count: 1
  end

  test 'new form should be for Publications if Publication passed in' do
    get :new, {document_type: 'Publication'}

    assert_select "input[type='hidden'][name='document_type'][value='Publication']", count: 1
  end

  test 'creating should create a new document' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    first_org = create(:organisation)
    second_org = create(:organisation)
    attributes = attributes_for(:document)

    post :create, document: attributes.merge(
      topic_ids: [first_topic.id, second_topic.id],
      organisation_ids: [first_org.id, second_org.id]
    )

    created_document = Document.last
    assert_equal attributes[:title], created_document.title
    assert_equal attributes[:body], created_document.body
    assert_equal [first_topic, second_topic], created_document.topics
    assert_equal [first_org, second_org], created_document.organisations
  end

  test 'creating should take the writer to the document page' do
    post :create, document: attributes_for(:document)

    assert_redirected_to admin_document_path(Document.last)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'creating with no document type should create a Policy' do
    post :create, document: attributes_for(:document)
    assert_equal 1, Policy.count
  end

  test 'creating with publication document type should create a Publication' do
    post :create, document: attributes_for(:document), document_type: 'Publication'
    assert_equal 1, Publication.count
  end

  test 'creating with invalid data should leave the writer in the document editor' do
    attributes = attributes_for(:document)
    post :create, document: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
    assert_template "documents/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = attributes_for(:document)
    post :create, document: attributes.merge(title: '')

    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'creating with invalid data should not show any attachment info' do
    attributes = attributes_for(:document)
    attributes[:attach_file] = fixture_file_upload('greenpaper.pdf')
    post :create, document: attributes.merge(title: '')

    assert_select "p.attachment", count: 0
  end

  test 'updating should save modified document attributes' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    document = create(:document, topics: [first_topic])

    put :update, id: document.id, document: { title: "new-title", body: "new-body", topic_ids: [second_topic.id] }

    saved_document = document.reload
    assert_equal "new-title", saved_document.title
    assert_equal "new-body", saved_document.body
    assert_equal [second_topic], saved_document.topics
  end

  test 'updating should take the writer to the document page' do
    document = create(:document)
    put :update, id: document.id, document: {title: 'new-title', body: 'new-body'}

    assert_redirected_to admin_document_path(document)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'updating with invalid data should not save the document' do
    attributes = attributes_for(:document)
    document = create(:document, attributes)
    put :update, id: document.id, document: attributes.merge(title: '')

    assert_equal attributes[:title], document.reload.title
    assert_template "documents/edit"
    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'updating a stale policy should render edit page with conflicting policy' do
    document = create(:draft_policy)
    lock_version = document.lock_version
    document.update_attributes!(title: "new title")

    put :update, id: document.to_param, document: document.attributes.merge(lock_version: lock_version)

    assert_template 'edit'
    conflicting_document = document.reload
    assert_equal conflicting_document, assigns[:conflicting_document]
    assert_equal conflicting_document.lock_version, assigns[:document].lock_version
    assert_equal %{This document has been saved since you opened it. Your version appears on the left and the latest version appears on the right. Please incorporate any relevant changes into your version and then save it.}, flash[:alert]
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
    put :submit, id: draft_document.to_param

    assert draft_document.reload.submitted?
  end

  test 'submitting should redirect back to show page' do
    draft_document = create(:draft_policy)
    put :submit, id: draft_document.to_param

    assert_redirected_to admin_document_path(draft_document)
    assert_equal "Your document has been submitted for review by a second pair of eyes", flash[:notice]
  end

  test 'publishing should redirect back to published documents' do
    submitted_document = create(:submitted_policy)
    login_as "Eddie", departmental_editor: true
    put :publish, id: submitted_document.to_param, document: {lock_version: submitted_document.lock_version}

    assert_redirected_to published_admin_documents_path
    assert_equal "The document #{submitted_document.title} has been published", flash[:notice]
  end

  test 'publishing should remove it from the set of submitted policies' do
    document_to_publish = create(:submitted_policy)
    login_as "Eddie", departmental_editor: true
    put :publish, id: document_to_publish.to_param, document: {lock_version: document_to_publish.lock_version}

    get :submitted
    refute assigns(:documents).include?(document_to_publish)
  end

  test 'failing to publish an document should set a flash' do
    document_to_publish = create(:submitted_policy)
    login_as "Willy Writer", departmental_editor: false
    put :publish, id: document_to_publish.to_param, document: {lock_version: document_to_publish.lock_version}

    assert_equal "Only departmental editors can publish policies", flash[:alert]
  end

  test 'failing to publish an document should redirect back to the document' do
    document_to_publish = create(:submitted_policy)
    login_as "Willy Writer", departmental_editor: false
    put :publish, id: document_to_publish.to_param, document: {lock_version: document_to_publish.lock_version}

    assert_redirected_to admin_document_path(document_to_publish)
  end

  test 'failing to publish a stale document should redirect back to the document' do
    policy_to_publish = create(:submitted_policy)
    lock_version = policy_to_publish.lock_version
    policy_to_publish.update_attributes!(title: "new title")
    login_as "Eddie", departmental_editor: true
    put :publish, id: policy_to_publish.to_param, document: {lock_version: lock_version}

    assert_redirected_to admin_document_path(policy_to_publish)
    assert_equal "This document has been edited since you viewed it; you are now viewing the latest version", flash[:alert]
  end

  test "cancelling a new document takes the user to the list of drafts" do
    get :new
    assert_select "a[href=#{admin_documents_path}]", text: /cancel/i, count: 1
  end

  test "cancelling an existing document takes the user to that document" do
    draft_policy = create(:draft_policy)
    get :edit, id: draft_policy.to_param
    assert_select "a[href=#{admin_document_path(draft_policy)}]", text: /cancel/i, count: 1
  end

  test 'updating a submitted policy with bad data should show errors' do
    attributes = attributes_for(:submitted_policy)
    submitted_policy = create(:submitted_policy, attributes)
    put :update, id: submitted_policy.to_param, document: attributes.merge(title: '')

    assert_template 'edit'
  end

  test "revising the published document should create a new draft document" do
    published_document = create(:published_policy)
    Document.stubs(:find).returns(published_document)
    draft_document = create(:draft_policy)
    published_document.expects(:build_draft).with(@user).returns(draft_document)
    draft_document.expects(:save).returns(true)

    post :revise, id: published_document.to_param
  end

  test "revising a published document redirects to edit for the new draft" do
    published_document = create(:published_policy)

    post :revise, id: published_document.to_param

    draft_document = Document.last
    assert_redirected_to edit_admin_document_path(draft_document.reload)
  end

  test "failing to revise an document should redirect to the existing draft" do
    published_document = create(:published_policy)
    existing_draft = create(:draft_policy, document_identity: published_document.document_identity)

    post :revise, id: published_document.to_param

    assert_redirected_to edit_admin_document_path(existing_draft)
    assert_equal "There is already an active draft for this document", flash[:alert]
  end

  test "don't show the publish button to user's who can't publish an document" do
    submitted_document = create(:submitted_policy)

    get :show, id: submitted_document.to_param

    assert_select "form[action='#{publish_admin_document_path(submitted_document)}']", count: 0
  end

  test "show the 'add supporting document' button for an unpublished document" do
    draft_document = create(:draft_policy)

    get :show, id: draft_document.to_param

    assert_select "a[href='#{new_admin_document_supporting_document_path(draft_document)}']"
  end

  test "don't show the 'add supporting document' button for a published document" do
    published_document = create(:published_policy)

    get :show, id: published_document.to_param

    assert_select "a[href='#{new_admin_document_supporting_document_path(published_document)}']", count: 0
  end

  test "should render the content using govspeak markup" do
    draft_document = create(:draft_policy, body: "body-text")

    govspeak_document = mock("govspeak-document")
    govspeak_document.stubs(:to_html).returns("body-text-as-govspeak")
    Govspeak::Document.stubs(:new).with("body-text").returns(govspeak_document)

    get :show, id: draft_document.to_param

    assert_select ".body", text: "body-text-as-govspeak"
  end

  test "show lists supporting documents" do
    draft_document = create(:draft_policy, body: "body-text")
    first_supporting_document = create(:supporting_document, document: draft_document)
    second_supporting_document = create(:supporting_document, document: draft_document)

    get :show, id: draft_document.to_param

    assert_select ".supporting_documents" do
      assert_select_object(first_supporting_document)
      assert_select_object(second_supporting_document)
    end
  end
end
