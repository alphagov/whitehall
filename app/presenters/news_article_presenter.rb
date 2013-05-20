class NewsArticlePresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  delegate_instance_methods_of NewsArticle

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
