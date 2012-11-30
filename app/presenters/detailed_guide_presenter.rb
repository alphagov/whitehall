class DetailedGuidePresenter < Draper::Base
  include EditionPresenterHelper

  decorates :detailed_guide

  def display_date_attribute_name
    :first_published_at
  end
end
