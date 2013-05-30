module WorldLocationNewsArticleHelper
  def find_world_location_news_article_in_locale!(locale, title)
    I18n.with_locale locale do
      WorldLocationNewsArticle.find_by_title!(title)
    end
  end
end

World(WorldLocationNewsArticleHelper)
