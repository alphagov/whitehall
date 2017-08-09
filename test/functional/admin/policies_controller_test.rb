require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  view_test "topics returns list of the policy's topics when JSON requested" do
    topics = [create(:topic), create(:topic)]
    policy_content_id = 'asfd-asdf-asdf-asdf'
    create(:classification_policy, policy_content_id: policy_content_id, classification: topics.first)
    create(:classification_policy, policy_content_id: policy_content_id, classification: topics.second)

    get :topics, params: { policy_id: policy_content_id }, format: :json
    assert_equal topics.first.id, json_response['topics'].first
    assert_equal topics.second.id, json_response['topics'].second
  end
end
