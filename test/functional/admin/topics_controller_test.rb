require 'test_helper'

class Admin::TopicsControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test "is an admin controller" do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test "creating a topic without a name shows errors" do
    post :create, topic: { name: "", description: "description" }
    assert_select ".form-errors"
  end

  test "creating a topic without a description shows errors" do
    post :create, topic: { name: "name", description: "" }
    assert_select ".form-errors"
  end

  test "updating without a description shows errors" do
    topic = create(:topic)
    put :update, id: topic.id, topic: {name: "Blah", description: ""}

    assert_select ".form-errors"
  end

  test "should be able to destroy a destroyable topic" do
    topic = create(:topic)
    delete :destroy, id: topic.id

    assert_response :redirect
    assert_equal "Topic destroyed", flash[:notice]
  end

  test "destroying a topic which has associated content" do
    topic_with_published_policy = create(:topic, documents: [build(:published_policy)])

    delete :destroy, id: topic_with_published_policy.id
    assert_equal "Cannot destroy topic with associated content", flash[:alert]
  end
end