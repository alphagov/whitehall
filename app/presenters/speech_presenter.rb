class SpeechPresenter < Draper::Base
  include EditionPresenterHelper

  decorates :speech

  def display_date_attribute_name
    :delivered_on
  end

  def delivered_on
    date_microformat(:delivered_on)
  end
end
