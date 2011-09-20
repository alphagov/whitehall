require 'test_helper'

class PoliciesControllerTest < ActionController::TestCase
  test 'saving should leave the writer in the policy editor' do
    post :create, :policy => {}
    assert_redirected_to edit_policy_path(Policy.last)
  end
  
  test 'updating should leave the writer in the policy editor' do
    policy = Policy.create!
    post :update, :id => policy.id, :policy => {}
    assert_redirected_to edit_policy_path(Policy.last)
  end
end
