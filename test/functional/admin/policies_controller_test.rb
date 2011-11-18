require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase

  setup do
    @user = login_as :policy_writer
  end

  test_controller_is_a Admin::BaseController

  test "new displays policy form" do
    get :new

    assert_select "form#document_new[action='#{admin_policies_path}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "select[name*='document[organisation_ids]']"
      assert_select "select[name*='document[topic_ids]']"
      assert_select "select[name*='document[ministerial_role_ids]']"
      assert_select "input[type='submit']"
    end
  end

  test "new form has previewable body" do
    get :new
    assert_select "textarea[name='document[body]'].previewable"
  end

  test 'creating should create a new policy' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    first_org = create(:organisation)
    second_org = create(:organisation)
    first_minister = create(:ministerial_role)
    second_minister = create(:ministerial_role)
    attributes = attributes_for(:policy)

    post :create, document: attributes.merge(
      topic_ids: [first_topic.id, second_topic.id],
      organisation_ids: [first_org.id, second_org.id],
      ministerial_role_ids: [first_minister.id, second_minister.id]
    )

    policy = Policy.last
    assert_equal attributes[:title], policy.title
    assert_equal attributes[:body], policy.body
    assert_equal [first_topic, second_topic], policy.topics
    assert_equal [first_org, second_org], policy.organisations
    assert_equal [first_minister, second_minister], policy.ministerial_roles
  end

  test 'creating should take the writer to the policy page' do
    post :create, document: attributes_for(:policy)

    assert_redirected_to admin_policy_path(Policy.last)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'creating with invalid data should leave the writer in the policy editor' do
    attributes = attributes_for(:policy)
    post :create, document: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
    assert_template "documents/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = attributes_for(:policy)
    post :create, document: attributes.merge(title: '')

    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'edit displays policy form' do
    policy = create(:policy)

    get :edit, id: policy

    assert_select "form#document_edit[action='#{admin_policy_path(policy)}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "select[name*='document[organisation_ids]']"
      assert_select "select[name*='document[topic_ids]']"
      assert_select "select[name*='document[ministerial_role_ids]']"
      assert_select "input[type='submit']"
    end
  end

  test "edit form has previewable body" do
    policy = create(:policy)
    get :edit, id: policy
    assert_select "textarea[name='document[body]'].previewable"
  end

  test 'updating should save modified policy attributes' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    first_org = create(:organisation)
    second_org = create(:organisation)
    first_minister = create(:ministerial_role)
    second_minister = create(:ministerial_role)

    policy = create(:policy, topics: [first_topic], organisations: [first_org], ministerial_roles: [first_minister])

    put :update, id: policy, document: {
      title: "new-title",
      body: "new-body",
      topic_ids: [second_topic.id],
      organisation_ids: [second_org.id],
      ministerial_role_ids: [second_minister.id]
    }

    policy.reload
    assert_equal "new-title", policy.title
    assert_equal "new-body", policy.body
    assert_equal [second_topic], policy.topics
    assert_equal [second_org], policy.organisations
    assert_equal [second_minister], policy.ministerial_roles
  end

  test 'updating should remove all topics, organisations and ministerial roles if none in params' do
    topic = create(:topic)
    org = create(:organisation)
    minister = create(:ministerial_role)

    policy = create(:policy, topics: [topic], organisations: [org], ministerial_roles: [minister])

    put :update, id: policy, document: {}

    policy.reload
    assert_equal [], policy.topics
    assert_equal [], policy.organisations
    assert_equal [], policy.ministerial_roles
  end

  test 'updating should take the writer to the policy page' do
    policy = create(:policy)
    put :update, id: policy, document: {title: 'new-title', body: 'new-body'}

    assert_redirected_to admin_policy_path(policy)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'updating records the user who changed the document' do
    policy = create(:policy)
    put :update, id: policy, document: {title: 'new-title', body: 'new-body'}
    assert_equal @user, policy.document_authors(true).last.user
  end

  test 'updating with invalid data should not save the policy' do
    attributes = attributes_for(:policy)
    policy = create(:policy, attributes)
    put :update, id: policy, document: attributes.merge(title: '')

    assert_equal attributes[:title], policy.reload.title
    assert_template "documents/edit"
    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'updating a stale policy should render edit page with conflicting policy' do
    policy = create(:draft_policy, topics: [build(:topic)], organisations: [build(:organisation)], ministerial_roles: [build(:ministerial_role)])
    lock_version = policy.lock_version
    policy.touch

    put :update, id: policy, document: { lock_version: lock_version }

    assert_template 'edit'
    conflicting_policy = policy.reload
    assert_equal conflicting_policy, assigns[:conflicting_document]
    assert_equal conflicting_policy.lock_version, assigns[:document].lock_version
    assert_equal %{This document has been saved since you opened it}, flash[:alert]
  end

  test "cancelling a new policy takes the user to the list of drafts" do
    get :new
    assert_select "a[href=#{admin_documents_path}]", text: /cancel/i, count: 1
  end

  test "cancelling an existing policy takes the user to that policy" do
    draft_policy = create(:draft_policy)
    get :edit, id: draft_policy
    assert_select "a[href=#{admin_policy_path(draft_policy)}]", text: /cancel/i, count: 1
  end

  test 'updating a submitted policy with bad data should show errors' do
    attributes = attributes_for(:submitted_policy)
    submitted_policy = create(:submitted_policy, attributes)
    put :update, id: submitted_policy, document: attributes.merge(title: '')

    assert_template 'edit'
  end

  test "show the 'add supporting document' button for an unpublished document" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    assert_select "a[href='#{new_admin_document_supporting_document_path(draft_policy)}']"
  end

  test "don't show the 'add supporting document' button for a published policy" do
    published_policy = create(:published_policy)

    get :show, id: published_policy

    assert_select "a[href='#{new_admin_document_supporting_document_path(published_policy)}']", count: 0
  end

  test "should render the content using govspeak markup" do
    draft_policy = create(:draft_policy, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: draft_policy

    assert_select ".body", text: "body-in-html"
  end

  test "show lists supporting documents when there are some" do
    draft_policy = create(:draft_policy)
    first_supporting_document = create(:supporting_document, document: draft_policy)
    second_supporting_document = create(:supporting_document, document: draft_policy)

    get :show, id: draft_policy

    assert_select ".supporting_documents" do
      assert_select_object(first_supporting_document) do
        assert_select "a[href='#{admin_supporting_document_path(first_supporting_document)}'] span.title", text: first_supporting_document.title
      end
      assert_select_object(second_supporting_document) do
        assert_select "a[href='#{admin_supporting_document_path(second_supporting_document)}'] span.title", text: second_supporting_document.title
      end
    end
  end

  test "show lists each document author once" do
    tom = create(:user, name: "Tom")
    dick = create(:user, name: "Dick")
    harry = create(:user, name: "Harry")

    draft_policy = create(:draft_policy, creator: tom)
    draft_policy.edit_as(dick)
    draft_policy.edit_as(harry)
    draft_policy.edit_as(dick)

    get :show, id: draft_policy

    assert_select ".authors", text: "Tom, Dick, and Harry"
  end

  test "doesn't show supporting documents list when empty" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    assert_select ".supporting_documents .supporting_document", count: 0
  end

  should_be_rejectable :policy
  should_be_force_publishable :policy
  should_be_able_to_delete_a_document :policy

  should_link_to_public_version_when_published :policy
  should_not_link_to_public_version_when_not_published :policy
end
