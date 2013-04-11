class WorldLocationNewsArticlePresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :world_location_news_article

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
