class WorldLocationNewsArticlePresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  delegate_instance_methods_of WorldLocationNewsArticle

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
