class WorldLocationNewsArticlePresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  delegate_instance_methods_of WorldLocationNewsArticle

  def organisations
    @orgs ||= model.worldwide_organisations.map { |wo| WorldwideOrganisationPresenter.new(wo, context) }
  end

  def sorted_organisations
    organisations.sort_by {|wo| wo.name }
  end

  def lead_organisations
    []
  end

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
