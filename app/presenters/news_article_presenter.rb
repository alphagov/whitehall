class NewsArticlePresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :news_article

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
