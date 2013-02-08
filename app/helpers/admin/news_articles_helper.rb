module Admin::NewsArticlesHelper

  def news_article_first_published_at_options(news_article)
    if news_article.imported?
      { include_blank: true }
    else
      { default: Time.zone.now }
    end
  end
end
