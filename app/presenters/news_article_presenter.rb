class NewsArticlePresenter < Struct.new(:model, :context)
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  news_article_methods = NewsArticle.instance_methods - Object.instance_methods
  delegate *news_article_methods, to: :model

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
