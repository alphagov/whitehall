class CaseStudyPresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :case_study

  def display_date_attribute_name
    :timestamp_for_sorting
  end
end
