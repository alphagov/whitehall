class CaseStudyPresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :case_study

end
