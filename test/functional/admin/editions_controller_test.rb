require 'test_helper'

class Admin::EditionsControllerAuthenticationTest < ActionController::TestCase
  tests Admin::EditionsController

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
    post :create, edition: attributes_for(:edition)

    assert_login_required
  end

  test 'guests should not be able to access edit' do
    edition = create(:edition)

    get :edit, id: edition.to_param

    assert_login_required
  end

  test 'guests should not be able to access update' do
    edition = create(:edition)
    put :update, id: edition.to_param, edition: attributes_for(:edition)

    assert_login_required
  end

  test 'guests should not be able to access publish' do
    edition = create(:edition)
    put :publish, id: edition.to_param

    assert_login_required
  end

  test 'guests should not be able to access revise' do
    edition = create(:edition)
    post :revise, id: edition.to_param

    assert_login_required
  end

  test 'guests should not be able to access show' do
    edition = create(:edition)
    get :show, id: edition.to_param

    assert_login_required
  end
end

class Admin::EditionsControllerTest < ActionController::TestCase
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

  test 'creating should create a new edition' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    attributes = attributes_for(:edition)
    post :create, edition: attributes.merge(topic_ids: [first_topic.id, second_topic.id])
    created_edition = Edition.last
    assert_equal attributes[:title], created_edition.title
    assert_equal attributes[:body], created_edition.body
    assert_equal [first_topic, second_topic], created_edition.topics
  end

  test 'creating should take the writer to the edition page' do
    post :create, edition: attributes_for(:edition)

    assert_redirected_to admin_edition_path(Edition.last)
    assert_equal 'The policy has been saved', flash[:notice]
  end

  test 'creating with no document type should create a Policy' do
    post :create, edition: attributes_for(:edition)
    assert_equal 1, Policy.count
  end

  test 'creating with publication document type should create a Publication' do
    post :create, edition: attributes_for(:edition), document_type: 'Publication'
    assert_equal 1, Publication.count
  end

  test 'creating with invalid data should leave the writer in the policy editor' do
    attributes = attributes_for(:edition)
    post :create, edition: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:edition).body, "the valid data should not have been lost"
    assert_template "editions/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = attributes_for(:edition)
    post :create, edition: attributes.merge(title: '')

    assert_equal 'There are some problems with the policy', flash.now[:alert]
  end

  test 'creating with invalid data should not show any attachment info' do
    attributes = attributes_for(:edition)
    attributes[:attach_file] = fixture_file_upload('greenpaper.pdf')
    post :create, edition: attributes.merge(title: '')

    assert_select "p.attachment", count: 0
  end

  test 'updating should take the writer to the edition page' do
    edition = create(:edition)
    put :update, id: edition.id, edition: {title: 'new-title', body: 'new-body'}

    assert_redirected_to admin_edition_path(edition)
    assert_equal 'The policy has been saved', flash[:notice]
  end

  test 'updating with invalid data should not save the edition' do
    attributes = attributes_for(:edition)
    edition = create(:edition, attributes)
    put :update, id: edition.id, edition: attributes.merge(title: '')

    assert_equal attributes[:title], edition.reload.title
    assert_template "editions/edit"
  end

  test 'updating with invalid data should set an alert in the flash' do
    attributes = attributes_for(:edition)
    edition = create(:edition, attributes)
    put :update, id: edition.id, edition: attributes.merge(title: '')

    assert_equal 'There are some problems with the policy', flash.now[:alert]
  end

  test 'updating a stale policy should render edit page with conflicting policy' do
    edition = create(:draft_edition)
    lock_version = edition.lock_version
    edition.update_attributes!(title: "new title")

    put :update, id: edition.to_param, edition: edition.attributes.merge(lock_version: lock_version)

    assert_template 'edit'
    conflicting_edition = edition.reload
    assert_equal conflicting_edition, assigns[:conflicting_edition]
    assert_equal conflicting_edition.lock_version, assigns[:edition].lock_version
    assert_equal %{This policy has been saved since you opened it. Your version appears on the left and the latest version appears on the right. Please incorporate any relevant changes into your version and then save it.}, flash[:alert]
  end

  test 'should distinguish between document types when viewing the list of draft documents' do
    policy = create(:draft_edition, document: create(:policy))
    publication = create(:draft_edition, document: create(:publication))
    get :index

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test 'should distinguish between document types when viewing the list of submitted documents' do
    policy = create(:submitted_edition, document: create(:policy))
    publication = create(:submitted_edition, document: create(:publication))
    get :submitted

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test 'should distinguish between document types when viewing the list of published documents' do
    policy = create(:published_edition, document: create(:policy))
    publication = create(:published_edition, document: create(:publication))
    get :published

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test 'viewing the list of submitted policies should not show draft policies' do
    draft_edition = create(:draft_edition)
    get :submitted

    refute assigns(:editions).include?(draft_edition)
  end

  test 'viewing the list of published policies should only show published policies' do
    published_editions = [create(:published_edition)]
    get :published

    assert_equal published_editions, assigns(:editions)
  end

  test 'submitting should set submitted on the edition' do
    draft_edition = create(:draft_edition)
    put :submit, id: draft_edition.to_param

    assert draft_edition.reload.submitted?
  end

  test 'submitting should redirect back to show page' do
    draft_edition = create(:draft_edition)
    put :submit, id: draft_edition.to_param

    assert_redirected_to admin_edition_path(draft_edition)
    assert_equal "Your policy has been submitted to your second pair of eyes", flash[:notice]
  end

  test 'publishing should redirect back to submitted policies' do
    submitted_edition = create(:submitted_edition)
    login_as "Eddie", departmental_editor: true
    put :publish, id: submitted_edition.to_param, edition: {lock_version: submitted_edition.lock_version}

    assert_redirected_to submitted_admin_editions_path
  end

  test 'publishing should remove it from the set of submitted policies' do
    edition_to_publish = create(:submitted_edition)
    login_as "Eddie", departmental_editor: true
    put :publish, id: edition_to_publish.to_param, edition: {lock_version: edition_to_publish.lock_version}

    get :submitted
    refute assigns(:editions).include?(edition_to_publish)
  end

  test 'failing to publish an edition should set a flash' do
    edition_to_publish = create(:submitted_edition)
    login_as "Willy Writer", departmental_editor: false
    put :publish, id: edition_to_publish.to_param, edition: {lock_version: edition_to_publish.lock_version}

    assert_equal "Only departmental editors can publish policies", flash[:alert]
  end

  test 'failing to publish an edition should redirect back to the edition' do
    edition_to_publish = create(:submitted_edition)
    login_as "Willy Writer", departmental_editor: false
    put :publish, id: edition_to_publish.to_param, edition: {lock_version: edition_to_publish.lock_version}

    assert_redirected_to admin_edition_path(edition_to_publish)
  end

  test 'failing to publish a stale edition should redirect back to the edition' do
    edition_to_publish = create(:submitted_edition)
    lock_version = edition_to_publish.lock_version
    edition_to_publish.update_attributes!(title: "new title")
    login_as "Eddie", departmental_editor: true
    put :publish, id: edition_to_publish.to_param, edition: {lock_version: lock_version}

    assert_redirected_to admin_edition_path(edition_to_publish)
    assert_equal "This policy has been edited since you viewed it; you are now viewing the latest version", flash[:alert]
  end

  test "submitted policies can't be set back to draft" do
    submitted_edition = create(:submitted_edition)
    get :edit, id: submitted_edition.to_param
    assert_select "input[type='checkbox'][name='policy[submitted]']", count: 0
  end

  test "cancelling a new edition takes the user to the list of drafts" do
    get :new
    assert_select "a[href=#{admin_editions_path}]", text: /cancel/i, count: 1
  end

  test "cancelling an existing edition takes the user to that edition" do
    draft_edition = create(:draft_edition)
    get :edit, id: draft_edition.to_param
    assert_select "a[href=#{admin_edition_path(draft_edition)}]", text: /cancel/i, count: 1
  end

  test 'updating a submitted policy with bad data should show errors' do
    attributes = attributes_for(:submitted_edition)
    submitted_edition = create(:submitted_edition, attributes)
    put :update, id: submitted_edition.to_param, edition: attributes.merge(title: '')

    assert_template 'edit'
  end

  test "revising a published edition redirects to edit for the new draft" do
    published_edition = create(:published_edition)

    post :revise, id: published_edition.to_param

    draft_edition = Edition.last
    assert_redirected_to edit_admin_edition_path(draft_edition.reload)
  end

  test "failing to revise an edition should redirect to the existing draft" do
    published_edition = create(:published_edition)
    existing_draft = create(:draft_edition, document: published_edition.document)

    post :revise, id: published_edition.to_param

    assert_redirected_to edit_admin_edition_path(existing_draft)
    assert_equal "There is already an active draft for this policy", flash[:alert]
  end

  test "don't show the publish button to user's who can't publish an edition" do
    submitted_edition = create(:submitted_edition)

    get :show, id: submitted_edition.to_param

    assert_select "form[action='#{publish_admin_edition_path(submitted_edition)}']", count: 0
  end

  test "should render the content using govspeak markup" do
    draft_edition = create(:draft_edition, body: "body-text")

    govspeak_document = mock("govspeak-document")
    govspeak_document.stubs(:to_html).returns("body-text-as-govspeak")
    Govspeak::Document.stubs(:new).with("body-text").returns(govspeak_document)

    get :show, id: draft_edition.to_param

    assert_select ".body", text: "body-text-as-govspeak"
  end
end
