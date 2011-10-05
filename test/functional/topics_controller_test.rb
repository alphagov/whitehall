require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  test "should only see published policies" do
    published_edition = build(:published_edition)
    topic = create(:topic, editions: [published_edition, build(:draft_edition)])

    get :show, id: topic.to_param

    assert_select_object(published_edition.document)
  end
end