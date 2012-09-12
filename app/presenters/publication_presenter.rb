class PublicationPresenter < Draper::Base
  include EditionPresenterHelper

  decorates :publication

  def display_date_attribute_name
    :publication_date
  end

  def display_publication_type
    publication_type.singular_name
  end
end
