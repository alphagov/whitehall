class CaseStudyPresenter < Draper::Base
  include LeadImagePresenterHelper

  decorates :case_study
end
