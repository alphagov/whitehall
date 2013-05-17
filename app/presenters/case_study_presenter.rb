class CaseStudyPresenter < Struct.new(:model, :context)
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  case_study_methods = CaseStudy.instance_methods - Object.instance_methods
  delegate *case_study_methods, to: :model

  private

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
