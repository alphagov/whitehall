require "test_helper"

class Admin::NewsArticlesHelperTest < ActionView::TestCase
  def assert_options(news_article, expected)
    assert_equal expected, news_article_first_published_at_options(news_article)
  end

  test "includes blank if imported" do
    news_article = create(:imported_news_article)
    assert_options(news_article, include_blank: true)
  end

  test "defaults to now if not imported" do
    news_article = create(:draft_news_article)
    assert_options(news_article, default: Time.zone.now)
  end
end
