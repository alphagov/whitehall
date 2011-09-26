require 'test_helper'

class Admin::EditionsControllerAuthenticationTest < ActionController::TestCase
  tests Admin::EditionsController

  test 'guests should not be able to access index' do
    get :index

    assert_login_required
  end

  test 'guests should not be able to access new' do
    get :new

    assert_login_required
  end

  test 'guests should not be able to access create' do
    post :create, edition: FactoryGirl.attributes_for(:edition)

    assert_login_required
  end

  test 'guests should not be able to access edit' do
    edition = FactoryGirl.create(:edition)

    get :edit, id: edition.to_param

    assert_login_required
  end

  test 'guests should not be able to access update' do
    edition = FactoryGirl.create(:edition)
    post :update, id: edition.to_param, edition: FactoryGirl.attributes_for(:edition)

    assert_login_required
  end

  test 'guests should not be able to access publish' do
    edition = FactoryGirl.create(:edition)
    put :publish, id: edition.to_param

    assert_login_required
  end
end

class Admin::EditionsControllerTest < ActionController::TestCase
  setup do
    login_as "George"
  end

  test 'saving should leave the writer in the policy editor' do
    post :create, edition: FactoryGirl.attributes_for(:edition)

    assert_redirected_to edit_admin_edition_path(Edition.last)
    assert_equal 'The policy has been saved', flash[:notice]
  end

  test 'creating with invalid data should leave the writer in the policy editor' do
    attributes = FactoryGirl.attributes_for(:edition)
    post :create, edition: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:edition).body, "the valid data should not have been lost"
    assert_template "editions/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = FactoryGirl.attributes_for(:edition)
    post :create, edition: attributes.merge(title: '')

    assert_equal 'There are some problems with the policy', flash.now[:alert]
  end

  test 'updating should leave the writer in the policy editor' do
    edition = FactoryGirl.create(:edition)
    post :update, id: edition.id, edition: {title: 'new-title', body: 'new-body'}

    assert_redirected_to edit_admin_edition_path(edition)
    assert_equal 'The policy has been saved', flash[:notice]
  end

  test 'updating with invalid data should not save the edition' do
    attributes = FactoryGirl.attributes_for(:edition)
    edition = FactoryGirl.create(:edition, attributes)
    post :update, id: edition.id, edition: attributes.merge(title: '')

    assert_equal attributes[:title], edition.reload.title
    assert_template "editions/edit"
  end

  test 'updating with invalid data should set an alert in the flash' do
    attributes = FactoryGirl.attributes_for(:edition)
    edition = FactoryGirl.create(:edition, attributes)
    post :update, id: edition.id, edition: attributes.merge(title: '')

    assert_equal 'There are some problems with the policy', flash.now[:alert]
  end

  test 'viewing the list of submitted policies should not show draft policies' do
    draft_edition = Factory.create(:draft_edition)
    get :submitted

    assert_not assigns(:editions).include?(draft_edition)
  end

  test 'publishing should redirect back to submitted policies' do
    submitted_edition = Factory.create(:submitted_edition)
    login_as "Eddie", departmental_editor: true
    put :publish, id: submitted_edition.to_param, edition: {lock_version: submitted_edition.lock_version}

    assert_redirected_to submitted_admin_editions_path
  end

  test 'publishing should remove it from the set of submitted policies' do
    edition_to_publish = Factory.create(:submitted_edition)
    login_as "Eddie", departmental_editor: true
    put :publish, id: edition_to_publish.to_param, edition: {lock_version: edition_to_publish.lock_version}

    get :submitted
    assert_not assigns(:editions).include?(edition_to_publish)
  end

  test 'failing to publish a edition should set a flash' do
    edition_to_publish = Factory.create(:submitted_edition)
    login_as "Willy Writer", departmental_editor: false
    put :publish, id: edition_to_publish.to_param, edition: {lock_version: edition_to_publish.lock_version}

    assert_equal "Only departmental editors can publish policies", flash[:alert]
  end

  test 'failing to publish a edition should redirect back to the edition' do
    edition_to_publish = Factory.create(:submitted_edition)
    login_as "Willy Writer", departmental_editor: false
    put :publish, id: edition_to_publish.to_param, edition: {lock_version: edition_to_publish.lock_version}

    assert_redirected_to admin_edition_path(edition_to_publish)
  end

  test "submitted policies can't be set back to draft" do
    submitted_edition = Factory.create(:submitted_edition)
    get :edit, :id => submitted_edition.to_param
    assert_select "input[type='checkbox'][name='policy[submitted]']", :count => 0
  end

  test "cancelling a submitted edition takes the user to the list of submissions" do
    submitted_edition = Factory.create(:submitted_edition)
    get :edit, :id => submitted_edition.to_param
    assert_select "a[href=#{submitted_admin_editions_path}]", :text => /cancel/i, :count => 1
  end

  test "cancelling a draft edition takes the user to the list of drafts" do
    draft_edition = Factory.create(:draft_edition)
    get :edit, :id => draft_edition.to_param
    assert_select "a[href=#{admin_editions_path}]", :text => /cancel/i, :count => 1
  end
end
