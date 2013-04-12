class CaseStudyPresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :case_study

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
