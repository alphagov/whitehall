require 'test_helper'

class Admin::TopicsControllerTest < ActionController::TestCase
  setup do
    @user = login_as "Damien"
  end

  test "is an admin controller" do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test "updating without a description shows errors" do
    topic = create(:topic)
    put :update, id: topic.id, topic: {name: "Blah", description: ""}

    assert_select ".form-errors"
  end
end