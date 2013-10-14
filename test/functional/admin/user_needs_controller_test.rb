require "test_helper"

class Admin::UserNeedsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "POST on :create creates a new user need" do
    data = { user: "test user", need: "this to work", goal: "pass my tests" }
    post :create, format: :json, user_need: data

    assert_response :success
    assert user_need = UserNeed.last

    assert_equal user_need.id, json_response["id"]
    assert_equal user_need.to_s, json_response["text"]
  end

  test "POST on :create with invalid data returns errors" do
    data = { user: "test user", need: "this to work", goal: "" }
    post :create, format: :json, user_need: data

    assert_response 422

    assert json_response["errors"].any?
  end
end

