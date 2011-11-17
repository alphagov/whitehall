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
      assert_select_object(published_policy, count: 1)
    end
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
      assert_select_object(published_article, count: 1)
    end
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

  test "show displays recently changed documents relating to the topic" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    news_article_1 = create(:published_news_article)
    news_article_2 = create(:published_news_article)
    topic = create(:topic, documents: [policy_1, policy_2, news_article_1, news_article_2])

    get :show, id: topic

    assert_select "#recently-changed" do
      assert_select_object policy_1
      assert_select_object policy_2
      assert_select_object news_article_1
      assert_select_object news_article_2
    end
  end

  test "show orders recently changed related documents most recent first" do
    policy_1 = create(:published_policy, published_at: 4.weeks.ago)
    policy_2 = create(:published_policy, published_at: 1.weeks.ago)
    news_article_1 = create(:published_news_article, published_at: 3.weeks.ago)
    news_article_2 = create(:published_news_article, published_at: 2.weeks.ago)
    topic = create(:topic, documents: [policy_1, policy_2, news_article_1, news_article_2])

    get :show, id: topic

    assert_equal [policy_2, news_article_2, news_article_1, policy_1], assigns[:recently_changed_documents]
  end

  test "show orders recently changed related documents most recent first ignoring admin ordering" do
    policy_1 = create(:published_policy, published_at: 1.weeks.ago)
    policy_2 = create(:published_policy, published_at: 2.weeks.ago)
    topic = create(:topic)
    create(:document_topic, topic: topic, document: policy_1, ordering: 2)
    create(:document_topic, topic: topic, document: policy_2, ordering: 1)

    get :show, id: topic

    assert_equal [policy_1, policy_2], assigns[:recently_changed_documents]
  end

  test "should show list of topics with published documents" do
    topic_1, topic_2 = create(:topic), create(:topic)
    Topic.stubs(:with_published_documents).returns([topic_1, topic_2])
    TopicsController::FeaturedTopicChooser.stubs(:choose_topic)

    get :index

    assert_select_object(topic_1)
    assert_select_object(topic_2)
  end

  test "should not display an empty list of topics" do
    Topic.stubs(:with_published_documents).returns([])
    TopicsController::FeaturedTopicChooser.stubs(:choose_topic)

    get :index

    assert_select ".topics", count: 0
  end

  test "shows a featured topic if one exists" do
    topic = create(:topic)
    TopicsController::FeaturedTopicChooser.stubs(:choose_topic).returns(topic)

    get :index

    assert_select ".featured" do
      assert_select_object(topic)
    end
  end

  test "shows featured topic policies" do
    policy = create(:published_policy)
    topic = create(:topic, documents: [policy])
    TopicsController::FeaturedTopicChooser.stubs(:choose_topic).returns(topic)

    get :index

    assert_select_object policy
  end

  test "shows featured topic news articles" do
    article = create(:published_news_article)
    topic = create(:topic, documents: [article])
    TopicsController::FeaturedTopicChooser.stubs(:choose_topic).returns(topic)

    get :index

    assert_select_object article
  end

  class FeaturedTopicChooserTest < ActiveSupport::TestCase
    test "chooses random featured topic if one exists" do
      TopicsController::FeaturedTopicChooser.stubs(:choose_random_featured_topic).returns(:random_featured_topic)
      TopicsController::FeaturedTopicChooser.expects(:choose_random_topic).never
      assert_equal :random_featured_topic, TopicsController::FeaturedTopicChooser.choose_topic
    end

    test "chooses random topic if no featured topics found" do
      TopicsController::FeaturedTopicChooser.stubs(:choose_random_featured_topic).returns(nil)
      TopicsController::FeaturedTopicChooser.expects(:choose_random_topic).returns(:random_topic)
      assert_equal :random_topic, TopicsController::FeaturedTopicChooser.choose_topic
    end
  end
end