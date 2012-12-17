class InternationalPriorityPresenter < Draper::Base
  include EditionPresenterHelper

  decorates :international_priority

  def display_date_attribute_name
    :first_published_at
  end
end
