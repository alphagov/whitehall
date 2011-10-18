require "test_helper"

class NewsArticleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    article = build(:news_article)
    assert article.valid?
  end
end