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
end