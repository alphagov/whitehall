require 'test_helper'

class Admin::PoliciesControllerAuthenticationTest < ActionController::TestCase
  tests Admin::PoliciesController

  test 'guests should not be able to access index' do
    get :index

    assert_login_required
  end

  test 'guests should not be able to access new' do
    get :new

    assert_login_required
  end

  test 'guests should not be able to access create' do
    post :create, policy: FactoryGirl.attributes_for(:policy)

    assert_login_required
  end

  test 'guests should not be able to access edit' do
    policy = FactoryGirl.create(:policy)

    get :edit, id: policy.to_param

    assert_login_required
  end

  test 'guests should not be able to access update' do
    policy = FactoryGirl.create(:policy)
    post :update, id: policy.to_param, policy: FactoryGirl.attributes_for(:policy)

    assert_login_required
  end

  test 'guests should not be able to access publish' do
    policy = FactoryGirl.create(:policy)
    post :publish, id: policy.to_param

    assert_login_required
  end
end

class Admin::PoliciesControllerTest < ActionController::TestCase
  setup do
    login_as "George"
  end

  test 'saving should leave the writer in the policy editor' do
    post :create, policy: FactoryGirl.attributes_for(:policy)

    assert_redirected_to edit_admin_policy_path(Policy.last)
    assert_equal 'The policy has been saved', flash[:notice]
  end

  test 'creating with invalid data should leave the writer in the policy editor' do
    attributes = FactoryGirl.attributes_for(:policy)
    post :create, policy: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:policy).body, "the valid data should not have been lost"
    assert_template "policies/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = FactoryGirl.attributes_for(:policy)
    post :create, policy: attributes.merge(title: '')

    assert_equal 'There are some problems with the policy', flash.now[:alert]
  end

  test 'updating should leave the writer in the policy editor' do
    policy = FactoryGirl.create(:policy)
    post :update, id: policy.id, policy: {title: 'new-title', body: 'new-body'}

    assert_redirected_to edit_admin_policy_path(policy)
    assert_equal 'The policy has been saved', flash[:notice]
  end

  test 'updating with invalid data should not save the policy' do
    attributes = FactoryGirl.attributes_for(:policy)
    policy = FactoryGirl.create(:policy, attributes)
    post :update, id: policy.id, policy: attributes.merge(title: '')

    assert_equal attributes[:title], policy.reload.title
    assert_template "policies/edit"
  end

  test 'updating with invalid data should set an alert in the flash' do
    attributes = FactoryGirl.attributes_for(:policy)
    policy = FactoryGirl.create(:policy, attributes)
    post :update, id: policy.id, policy: attributes.merge(title: '')

    assert_equal 'There are some problems with the policy', flash.now[:alert]
  end

  test 'viewing the list of submitted policies should not show draft policies' do
    draft_policy = Factory.create(:draft_policy)
    get :submitted

    assert_not assigns(:policies).include?(draft_policy)
  end

  test 'publishing should redirect back to submitted policies' do
    submitted_policy = Factory.create(:submitted_policy)
    post :publish, id: submitted_policy.to_param

    assert_redirected_to submitted_admin_policies_path
  end

  test 'publishing should remove it from the set of submitted policies' do
    policy_to_publish = Factory.create(:submitted_policy)
    login_as "Eddie", departmental_editor: true
    post :publish, id: policy_to_publish.to_param

    get :submitted
    assert_not assigns(:policies).include?(policy_to_publish)
  end
  
  test "submitted policies can't be set back to draft" do
    submitted_policy = Factory.create(:submitted_policy)
    get :edit, :id => submitted_policy.to_param
    assert_select "input[type='checkbox'][name='policy[submitted]']", :count => 0
  end
  
  test "cancelling a submitted policy takes the user to the list of submissions" do
    submitted_policy = Factory.create(:submitted_policy)
    get :edit, :id => submitted_policy.to_param
    assert_select "a[href=#{submitted_admin_policies_path}]", :text => /cancel/i, :count => 1
  end
  
  test "cancelling a draft policy takes the user to the list of drafts" do
    draft_policy = Factory.create(:draft_policy)
    get :edit, :id => draft_policy.to_param
    assert_select "a[href=#{admin_policies_path}]", :text => /cancel/i, :count => 1
  end
end
