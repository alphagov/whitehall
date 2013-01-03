class CaseStudyPresenter < Draper::Base
  include EditionPresenterHelper
  include LeadImagePresenterHelper

  decorates :case_study

  def display_date_attribute_name
    :public_timestamp
  end
end
