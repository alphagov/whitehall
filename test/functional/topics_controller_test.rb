require "test_helper"

class TopicsControllerTest < ActionController::TestCase
  test "shows topic title and description" do
    topic = create(:topic)
    get :show, id: topic.to_param
    assert_select ".topic .name", text: topic.name
    assert_select ".topic .description", text: topic.description
  end

  test "shows only published policies associated with topic" do
    published_policy = create(:published_policy)
    topic = create(:topic, editions: [published_policy.published_edition, build(:draft_edition)])
    get :show, id: topic.to_param
    assert_select_object(published_policy)
  end
end