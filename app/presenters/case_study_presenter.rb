class CaseStudyPresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  delegate_instance_methods_of CaseStudy

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
