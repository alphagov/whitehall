require "test_helper"

class NewsArticleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    article = build(:news_article)
    assert article.valid?
  end

  test "should be able to relate to other documents" do
    article = build(:news_article)
    assert article.can_be_related_to_other_documents?
  end
end