class WorldLocationNewsArticlePresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :world_location_news_article

  def lead_image_path
    image = super
    if image =~ /placeholder/ && news_article.organisations.any? && find_asset("organisation_default_news/s300_#{news_article.organisations.first.slug}.jpg")
      "organisation_default_news/s300_#{news_article.organisations.first.slug}.jpg"
    else
      image
    end
  end

  def organisations
    @orgs ||= model.worldwide_organisations.map { |wo| WorldwideOrganisationPresenter.new(wo) }
  end

  def lead_organisations
    []
  end

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
