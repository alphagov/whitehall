class NewsArticlePresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :news_article

  def display_date_attribute_name
    :published_at
  end
end
