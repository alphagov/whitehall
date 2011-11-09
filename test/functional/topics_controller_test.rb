require "test_helper"

class TopicsControllerTest < ActionController::TestCase
  test "shows topic title and description" do
    topic = create(:topic)
    get :show, id: topic
    assert_select ".topic .name", text: topic.name
    assert_select ".topic .description", text: topic.description
  end

  test "shows published policies associated with topic" do
    published_policy = create(:published_policy)
    topic = create(:topic, documents: [published_policy])

    get :show, id: topic

    assert_select "#policies" do
      assert_select_object(published_policy)
    end

    assert_select_object(published_policy, count: 1)
  end

  test "doesn't show unpublished policies" do
    draft_policy = create(:draft_news_article)
    topic = create(:topic, documents: [draft_policy])

    get :show, id: topic

    assert_select_object(draft_policy, count: 0)
  end

  test "should not display an empty published policies section" do
    topic = create(:topic)
    get :show, id: topic
    assert_select "#policies", count: 0
  end

  test "shows published news articles associated with topic" do
    published_article = create(:published_news_article)
    topic = create(:topic, documents: [published_article])

    get :show, id: topic

    assert_select "#news_articles" do
      assert_select_object(published_article)
    end

    assert_select_object(published_article, count: 1)
  end

  test "doesn't show unpublished news articles" do
    draft_article = create(:draft_news_article)
    topic = create(:topic, documents: [draft_article])

    get :show, id: topic

    assert_select_object(draft_article, count: 0)
  end

  test "should not display an empty news articles section" do
    topic = create(:topic)
    get :show, id: topic
    assert_select "#news_articles", count: 0
  end

  test "should show list of topics with published documents" do
    topic_1, topic_2 = create(:topic), create(:topic)
    Topic.stubs(:with_published_documents).returns([topic_1, topic_2])
    Topic.stubs(:featured).returns([])

    get :index

    assert_select_object(topic_1)
    assert_select_object(topic_2)
  end

  test "should not display an empty list of topics" do
    Topic.stubs(:with_published_documents).returns([])
    Topic.stubs(:featured).returns([])

    get :index

    assert_select ".topics", count: 0
  end

  test "shows a featured topic if one exists" do
    topic = create(:topic)
    Topic.stubs(:featured).returns([topic])

    get :index

    assert_select ".featured" do
      assert_select_object(topic)
    end
  end
end