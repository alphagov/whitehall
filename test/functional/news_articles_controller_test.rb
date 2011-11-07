require 'test_helper'

class NewsArticlesControllerTest < ActionController::TestCase
  test "shows published news articles" do
    news_article = create(:published_news_article)
    get :show, id: news_article.document_identity
    assert_response :success
  end

  test "should not display related policies unless they are published" do
    draft_policy = create(:draft_policy)
    news_article = create(:published_news_article, documents_related_to: [draft_policy])
    get :show, id: news_article.document_identity
    assert_select_object draft_policy, count: 0
  end

  test "should not display policies unless they are related to the news article" do
    unrelated_policy = create(:published_policy)
    news_article = create(:published_news_article, documents_related_to: [])
    get :show, id: news_article.document_identity
    assert_select_object unrelated_policy, count: 0
  end

  test "should not display an empty list of related policies" do
    news_article = create(:published_news_article)
    get :show, id: news_article.document_identity
    assert_select "#related-policies", count: 0
  end

  test "index lists newest articles first" do
    article_a = create(:published_news_article, title: 'A', created_at: 2.hours.ago)
    article_c = create(:published_news_article, title: 'C', created_at: 4.hours.ago)
    article_b = create(:published_news_article, title: 'B', created_at: 1.hour.ago)

    get :index

    assert_equal [article_b, article_a, article_c], assigns[:articles]
  end

  test "index includes published articles" do
    news_article = create(:published_news_article)
    get :index
    assert_select_object news_article
  end

  test "index excludes unpublished articles" do
    news_article = create(:draft_news_article)
    get :index
    assert_select_object news_article, count: 0
  end

  test "index excludes other published documents" do
    policy = create(:published_policy)
    get :index
    assert_select_object policy, count: 0
  end
end