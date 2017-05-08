module NewsArticleHelper
  def find_news_article_in_locale!(locale, title)
    I18n.with_locale locale do
      NewsArticle.find_by!(title: title)
    end
  end
end

World(NewsArticleHelper)
