require 'test_helper'

class Admin::PublicationsControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test 'is an admin controller' do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test 'creating should create a new publication' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    first_org = create(:organisation)
    second_org = create(:organisation)
    first_policy = create(:published_policy)
    second_policy = create(:published_policy)
    attributes = attributes_for(:publication)

    post :create, document: attributes.merge(
      organisation_ids: [first_org.id, second_org.id],
      documents_related_to_ids: [first_policy.id, second_policy.id]
    )

    created_publication = Publication.last
    assert_equal attributes[:title], created_publication.title
    assert_equal attributes[:body], created_publication.body
    assert_equal [first_org, second_org], created_publication.organisations
    assert_equal [first_policy, second_policy], created_publication.documents_related_to
  end

  test 'creating should take the writer to the publication page' do
    post :create, document: attributes_for(:publication)

    assert_redirected_to admin_publication_path(Publication.last)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'creating with invalid data should leave the writer in the publication editor' do
    attributes = attributes_for(:publication)
    post :create, document: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
    assert_template "documents/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = attributes_for(:publication)
    post :create, document: attributes.merge(title: '')

    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'creating a publication with invalid data should not show any attachment info' do
    attributes = attributes_for(:publication)
    attributes[:attach_file] = fixture_file_upload('greenpaper.pdf')
    post :create, document: attributes.merge(title: '')

    assert_select "p.attachment", count: 0
  end

  test 'updating should save modified document attributes' do
    publication = create(:publication)

    put :update, id: publication.id, document: { title: "new-title", body: "new-body" }

    saved_publication = publication.reload
    assert_equal "new-title", saved_publication.title
    assert_equal "new-body", saved_publication.body
  end

  test 'updating should take the writer to the publication page' do
    publication = create(:publication)
    put :update, id: publication.id, document: {title: 'new-title', body: 'new-body'}

    assert_redirected_to admin_publication_path(publication)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'updating with invalid data should not save the publication' do
    attributes = attributes_for(:publication)
    publication = create(:publication, attributes)
    put :update, id: publication.id, document: attributes.merge(title: '')

    assert_equal attributes[:title], publication.reload.title
    assert_template "documents/edit"
    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'updating a stale publication should render edit page with conflicting publication' do
    publication = create(:draft_publication)
    lock_version = publication.lock_version
    publication.update_attributes!(title: "new title")

    put :update, id: publication, document: publication.attributes.merge(lock_version: lock_version)

    assert_template 'edit'
    conflicting_publication = publication.reload
    assert_equal conflicting_publication, assigns[:conflicting_document]
    assert_equal conflicting_publication.lock_version, assigns[:document].lock_version
    assert_equal %{This document has been saved since you opened it}, flash[:alert]
  end

  test "cancelling a new publication takes the user to the list of drafts" do
    get :new
    assert_select "a[href=#{admin_documents_path}]", text: /cancel/i, count: 1
  end

  test "cancelling an existing publication takes the user to that publication" do
    draft_publication = create(:draft_publication)
    get :edit, id: draft_publication
    assert_select "a[href=#{admin_publication_path(draft_publication)}]", text: /cancel/i, count: 1
  end

  test 'updating a submitted publication with bad data should show errors' do
    attributes = attributes_for(:submitted_publication)
    submitted_publication = create(:submitted_publication, attributes)
    put :update, id: submitted_publication, document: attributes.merge(title: '')

    assert_template 'edit'
  end

  test "should render the content using govspeak markup" do
    draft_publication = create(:draft_publication, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: draft_publication

    assert_select ".body", text: "body-in-html"
  end

  should_show_who_rejected_the :publication
  should_show_the_list_of_editorial_remarks :publication
  should_be_able_to_delete_a_document :publication

  should_link_to_public_version_when_published :publication
  should_not_link_to_public_version_when_not_published :publication
end
