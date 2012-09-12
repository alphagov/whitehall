class PublicationPresenter < Draper::Base
  include EditionPresenterHelper

  decorates :publication

  def display_date_attribute_name
    :publication_date
  end
end
