require "test_helper"

class NewsArticleTypeTest < ActiveSupport::TestCase
  test "should provide slugs for every news article type" do
    news_article_types = NewsArticleType.all
    assert_equal news_article_types.length, news_article_types.map(&:slug).compact.length
  end

  test "should be findable by slug" do
    news_article_type = NewsArticleType.find_by_id(1)
    assert_equal news_article_type, NewsArticleType.find_by_slug(news_article_type.slug)
  end

  test "should list all slugs" do
    assert_equal "news-stories, press-releases, government-responses, worldwide-news-stories and announcements", NewsArticleType.all_slugs
  end

  test 'search_format_types tags the type with the key, prefixed with news-article-' do
    NewsArticleType.all.each do |news_article_type|
      assert news_article_type.search_format_types.include?('news-article-' + news_article_type.key.gsub('_', ' ').parameterize)
    end
  end
end
