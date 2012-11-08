class AnnouncementPresenter < Draper::Base
  include EditionPresenterHelper

  decorates :announcement

  def display_date_attribute_name
    case announcement
    when Speech
      :delivered_on
    when NewsArticle
      :first_published_at
    else
      raise "Unexpected type: #{announcement.type}"
    end
  end
end
