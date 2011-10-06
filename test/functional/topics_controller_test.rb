require "test_helper"

class TopicsControllerTest < ActionController::TestCase
  test "shows topic title and description" do
    topic = create(:topic)
    get :show, id: topic.to_param
    assert_select ".topic .name", text: topic.name
    assert_select ".topic .description", text: topic.description
  end

  test "shows only published policies associated with topic" do
    published_edition = create(:published_edition)
    draft_edition = create(:draft_edition)
    topic = create(:topic, editions: [published_edition, draft_edition])
    get :show, id: topic.to_param
    assert_select_object(published_edition.document)
    assert_select_object(draft_edition.document, count: 0)
  end

  test "shows only published publications associated with topic" do
    published_edition = create(:published_edition, document: build(:publication))
    draft_edition = create(:draft_edition, document: build(:publication))
    topic = create(:topic, editions: [published_edition, draft_edition])
    get :show, id: topic.to_param
    assert_select_object(published_edition.document)
    assert_select_object(draft_edition.document, count: 0)
  end

  test "should not display an empty published policies section" do
    topic = create(:topic)
    get :show, id: topic.to_param
    assert_select "#policies", count: 0
  end

  test "should not display an empty published publications section" do
    topic = create(:topic)
    get :show, id: topic.to_param
    assert_select "#publications", count: 0
  end

  test "should show list of topics with published documents" do
    topic_1, topic_2 = create(:topic), create(:topic)
    Topic.stubs(:with_published_documents).returns([topic_1, topic_2])

    get :index

    assert_select_object(topic_1)
    assert_select_object(topic_2)
  end

  test "should not display an empty list of topics" do
    Topic.stubs(:with_published_documents).returns([])

    get :index

    assert_select ".topics", count: 0
  end
end