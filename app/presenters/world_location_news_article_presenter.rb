class WorldLocationNewsArticlePresenter < Struct.new(:model, :context)
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  world_location_news_article_methods = WorldLocationNewsArticle.instance_methods - Object.instance_methods
  delegate *world_location_news_article_methods, to: :model

  def organisations
    @orgs ||= model.worldwide_organisations.map { |wo| WorldwideOrganisationPresenter.new(wo, context) }
  end

  def lead_organisations
    []
  end

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
