require 'test_helper'

class NewsArticlesControllerTest < ActionController::TestCase
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

  test "index links to published news articles" do
    news_article = create(:published_news_article, title: "news-article-title")
    get :index
    assert_select "#news_articles" do
      assert_select_object news_article do
        assert_select "a[href=#{news_article_path(news_article.document_identity)}]"
        assert_select ".title", text: "news-article-title"
      end
    end
  end

  test "index lists newest news articles first" do
    oldest_article = create(:published_news_article, title: 'oldest', published_at: 4.hours.ago)
    newest_article = create(:published_news_article, title: 'newest', published_at: 2.hours.ago)
    get :index
    assert_equal [newest_article, oldest_article], assigns[:news_articles]
  end

  test "index excludes unpublished news articles" do
    news_article = create(:draft_news_article)
    get :index
    assert_select_object news_article, count: 0
  end

  test "index doesn't display an empty list if there aren't any news articles" do
    get :index
    assert_select "#news_articles ul", count: 0
  end
end