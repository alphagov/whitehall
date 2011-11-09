module NewsArticleTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_render_a_list_of_news_articles
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

      test "index excludes unpublished news articles" do
        news_article = create(:draft_news_article)
        get :index
        assert_select_object news_article, count: 0
      end

      test "index lists newest news articles first" do
        oldest_article = create(:published_news_article, title: 'oldest', published_at: 4.hours.ago)
        newest_article = create(:published_news_article, title: 'newest', published_at: 2.hours.ago)
        get :index
        assert_equal [newest_article, oldest_article], assigns[:news_articles]
      end

      test "index doesn't display an empty list if there aren't any news articles" do
        get :index
        assert_select "#news_articles ul", count: 0
      end
    end
  end
end