require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  test "should only see published policies" do
    published_policy = build(:published_policy)
    topic = create(:topic, documents: [published_policy, build(:draft_policy)])

    get :show, id: topic.to_param

    assert_select_object(published_policy)
  end
end