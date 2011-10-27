require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test 'is an admin controller' do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test "new displays policy form" do
    get :new

    assert_select "form[action='#{admin_policies_path}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "select[name*='document[organisation_ids]']"
      assert_select "select[name*='document[topic_ids]']"
      assert_select "select[name*='document[ministerial_role_ids]']"
      assert_select "input[name*='document[nation_inapplicabilities_attributes]'][type='checkbox']", count: 4
      assert_select "input[name*='document[nation_inapplicabilities_attributes]'][type='text']", count: 4
      assert_select "input[type='submit']"
    end
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
      ministerial_role_ids: [first_minister.id, second_minister.id],
      nation_inapplicabilities_attributes: {"0" => {_destroy: true, nation_id: Nation.england}, "1" => {_destroy: true, nation_id: Nation.scotland}, "2" => {_destroy: false, nation_id: Nation.wales, alternative_url: "http://www.visitwales.co.uk/"}, "3" => {_destroy: false, nation_id: Nation.northern_ireland}}
    )

    policy = Policy.last
    assert_equal attributes[:title], policy.title
    assert_equal attributes[:body], policy.body
    assert_equal [first_topic, second_topic], policy.topics
    assert_equal [first_org, second_org], policy.organisations
    assert_equal [first_minister, second_minister], policy.ministerial_roles
    assert_equal [Nation.wales, Nation.northern_ireland], policy.inapplicable_nations
    assert_equal "http://www.visitwales.co.uk/", policy.nation_inapplicabilities.for_nation(Nation.wales).first.alternative_url
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
    northern_ireland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.discovernorthernireland.com/")

    get :edit, id: policy

    assert_select "form[action='#{admin_policy_path(policy)}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "select[name*='document[organisation_ids]']"
      assert_select "select[name*='document[topic_ids]']"
      assert_select "select[name*='document[ministerial_role_ids]']"
      assert_select "input[name*='document[nation_inapplicabilities_attributes]'][type='checkbox']", count: 4
      assert_select "input[name*='document[nation_inapplicabilities_attributes]'][type='checkbox'][checked='checked']", count: 1
      assert_select "input[name*='document[nation_inapplicabilities_attributes]'][type='text']", count: 4
      assert_select "input[name*='document[nation_inapplicabilities_attributes]'][type='text'][value='http://www.discovernorthernireland.com/']", count: 1
      assert_select "input[type='submit']"
    end
  end

  test 'updating should save modified document attributes' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    first_org = create(:organisation)
    second_org = create(:organisation)
    first_minister = create(:ministerial_role)
    second_minister = create(:ministerial_role)

    policy = create(:policy, topics: [first_topic], organisations: [first_org], ministerial_roles: [first_minister])
    northern_ireland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.discovernorthernireland.com/")

    put :update, id: policy.id, document: {
      title: "new-title",
      body: "new-body",
      topic_ids: [second_topic.id],
      organisation_ids: [second_org.id],
      ministerial_role_ids: [second_minister.id],
      nation_inapplicabilities_attributes: {"0" => {_destroy: true, nation_id: Nation.england}, "1" => {_destroy: false, nation_id: Nation.scotland, alternative_url: "http://www.visitscotland.com/"}, "2" => {_destroy: true, nation_id: Nation.wales}, "3" => {id: northern_ireland_inapplicability, _destroy: true, nation_id: northern_ireland_inapplicability.nation_id, alternative_url: "http://www.discovernorthernireland.com/"}}
    }

    saved_policy = policy.reload
    assert_equal "new-title", saved_policy.title
    assert_equal "new-body", saved_policy.body
    assert_equal [second_topic], saved_policy.topics
    assert_equal [second_org], saved_policy.organisations
    assert_equal [second_minister], saved_policy.ministerial_roles
    assert_equal [Nation.scotland], saved_policy.inapplicable_nations
    assert_equal "http://www.visitscotland.com/", policy.nation_inapplicabilities.for_nation(Nation.scotland).first.alternative_url
  end

  test 'updating should take the writer to the policy page' do
    policy = create(:policy)
    put :update, id: policy.id, document: {title: 'new-title', body: 'new-body'}

    assert_redirected_to admin_policy_path(policy)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'updating with invalid data should not save the policy' do
    attributes = attributes_for(:policy)
    policy = create(:policy, attributes)
    put :update, id: policy.id, document: attributes.merge(title: '')

    assert_equal attributes[:title], policy.reload.title
    assert_template "documents/edit"
    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'updating a stale policy should render edit page with conflicting policy' do
    policy = create(:draft_policy, topics: [build(:topic)], organisations: [build(:organisation)], ministerial_roles: [build(:ministerial_role)], inapplicable_nations: [Nation.scotland])
    lock_version = policy.lock_version
    policy.update_attributes!(title: "new title")

    put :update, id: policy, document: policy.attributes.merge(lock_version: lock_version)

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

  test "doesn't show supporting documents list when empty" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    assert_select ".supporting_documents .supporting_document", count: 0
  end

  test "show lists nation inapplicabilities when there are some" do
    draft_policy = create(:draft_policy)
    scotland_inapplicability = draft_policy.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://scotland.com/")
    wales_inapplicability = draft_policy.nation_inapplicabilities.create!(nation: Nation.wales)

    get :show, id: draft_policy

    assert_select ".nation_inapplicabilities" do
      assert_select_object scotland_inapplicability, text: /Scotland/ do
        assert_select ".alternative_url a[href='http://scotland.com/']"
      end
      assert_select_object wales_inapplicability, text: /Wales/ do
        assert_select ".alternative_url a", count: 0
      end
    end
  end

  test "show explains the document applies to the whole of the UK" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    assert_select "p", "This document applies to the whole of the UK."
  end
end
