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

  test "show displays recently changed documents relating to policies in the topic" do
    policy_1 = create(:published_policy)
    publication_1 = create(:published_publication, documents_related_to: [policy_1])
    news_article_1 = create(:published_news_article, documents_related_to: [policy_1])
    consultation = create(:published_consultation, documents_related_to: [policy_1])

    policy_2 = create(:published_policy)
    news_article_2 = create(:published_news_article, documents_related_to: [policy_2])
    publication_2 = create(:published_publication, documents_related_to: [policy_2])
    speech = create(:published_speech, documents_related_to: [policy_2])

    topic = create(:topic, documents: [policy_1, policy_2])

    get :show, id: topic

    assert_select "#recently-changed" do
      assert_select_object news_article_1
      assert_select_object news_article_2
      assert_select_object publication_1
      assert_select_object publication_2
      assert_select_object consultation
      assert_select_object speech
    end
  end

  test "show displays metadata about the recently changed documents" do
    speech = create(:published_speech_transcript)
    policy = create(:published_policy,
      documents_related_with: [speech]
    )

    topic = create(:topic, documents: [policy])

    get :show, id: topic

    assert_select "#recently-changed" do
      assert_select_object speech do
        assert_select '.metadata .document_type', text: "Speech"
        assert_select '.metadata .time', count: 1
      end
    end
  end

  test "show displays recently changed documents in order of publication date with most recent first" do
    policy_1 = create(:published_policy)
    publication_1 = create(:published_publication, published_at: 4.weeks.ago, documents_related_to: [policy_1])
    news_article_1 = create(:published_news_article, published_at: 1.week.ago, documents_related_to: [policy_1])

    policy_2 = create(:published_policy)
    news_article_2 = create(:published_news_article, published_at: 3.weeks.ago, documents_related_to: [policy_2])
    publication_2 = create(:published_publication, published_at: 2.weeks.ago, documents_related_to: [policy_2])

    topic = create(:topic, documents: [policy_1, policy_2])

    get :show, id: topic

    assert_equal [news_article_1, publication_2, news_article_2, publication_1], assigns[:recently_changed_documents]
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