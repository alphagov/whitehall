require 'test_helper'

class NewsArticlesControllerTest < ActionController::TestCase
  should_render_a_list_of :news_articles

  test "shows published news article" do
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

  test "should display countries to which this news article relates" do
    first_country = create(:country)
    second_country = create(:country)
    news_article = create(:published_news_article, countries: [first_country, second_country])

    get :show, id: news_article.document_identity

    assert_select "#countries" do
      assert_select_object(first_country)
      assert_select_object(second_country)
    end
  end

  test "should not display an empty list of countries" do
    news_article = create(:published_news_article, countries: [])

    get :show, id: news_article.document_identity

    assert_select "#countries", count: 0
  end
end