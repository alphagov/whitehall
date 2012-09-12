class ConsultationPresenter < Draper::Base
  include EditionPresenterHelper
  include ConsultationsHelper

  decorates :consultation

  def display_date_attribute_name
    :first_published_at
  end

  def display_publication_type
    consultation_header_title(self)
  end

  def part_of_series?
    false
  end
end
