require 'test_helper'

class PoliciesControllerTest < ActionController::TestCase
  test 'saving should leave the writer in the policy editor' do
    post :create, :policy => FactoryGirl.attributes_for(:policy)

    assert_redirected_to edit_policy_path(Policy.last)
    assert_equal 'The policy has been saved', flash[:notice]
  end

  test 'creating with invalid data should leave the writer in the policy editor' do
    attributes = FactoryGirl.attributes_for(:policy)
    post :create, :policy => attributes.merge(:title => '')

    assert_equal attributes[:body], assigns(:policy).body, "the valid data should not have been lost"
    assert_template "policies/new"
  end

  test 'creating with invalid data should set a warning in the flash' do
    attributes = FactoryGirl.attributes_for(:policy)
    post :create, :policy => attributes.merge(:title => '')

    assert_equal 'There are some problems with the policy', flash.now[:warning]
  end

  test 'updating should leave the writer in the policy editor' do
    policy = FactoryGirl.create(:policy)
    post :update, :id => policy.id, :policy => {:title => 'new-title', :body => 'new-body'}

    assert_redirected_to edit_policy_path(policy)
    assert_equal 'The policy has been saved', flash[:notice]
  end

  test 'updating with invalid data should not save the policy' do
    attributes = FactoryGirl.attributes_for(:policy)
    policy = FactoryGirl.create(:policy, attributes)
    post :update, :id => policy.id, :policy => attributes.merge(:title => '')

    assert_equal attributes[:title], policy.reload.title
    assert_template "policies/edit"
  end

  test 'updating with invalid data should set a warning in the flash' do
    attributes = FactoryGirl.attributes_for(:policy)
    policy = FactoryGirl.create(:policy, attributes)
    post :update, :id => policy.id, :policy => attributes.merge(:title => '')

    assert_equal 'There are some problems with the policy', flash.now[:warning]
  end
end
