require "test_helper"

class TopicsControllerTest < ActionController::TestCase
  test "shows topic title and description" do
    topic = create(:topic)
    get :show, id: topic
    assert_select ".topic .name", text: topic.name
    assert_select ".topic .description", text: topic.description
  end

  test "shows only published policies associated with topic" do
    published_document = create(:published_policy)
    draft_document = create(:draft_policy)
    topic = create(:topic, documents: [published_document, draft_document])
    get :show, id: topic
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
  end

  test "shows only published news articles associated with topic" do
    published_document = create(:published_news_article)
    draft_document = create(:draft_news_article)
    topic = create(:topic, documents: [published_document, draft_document])
    get :show, id: topic
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
  end

  test "should not display an empty published policies section" do
    topic = create(:topic)
    get :show, id: topic
    assert_select "#policies", count: 0
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