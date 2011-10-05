require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  test "shows only published policies" do
    published_policy = create(:published_policy)
    topic = create(:topic, editions: [published_policy.published_edition, build(:draft_edition)])

    get :show, id: topic.to_param

    assert_select_object(published_policy)
  end
end