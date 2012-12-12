class NewsArticlePresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :news_article

  def display_date_attribute_name
    :published_at
  end

  def lead_image_path
    image = super
    if image =~ /placeholder/ && news_article.organisations.any? && find_asset("organisation_default_news/#{news_article.organisations.first.slug}.jpg")
      "organisation_default_news/#{news_article.organisations.first.slug}.jpg"
    else
      image
    end
  end

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
