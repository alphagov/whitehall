class WorldLocationNewsArticlePresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  delegate_instance_methods_of WorldLocationNewsArticle
end
