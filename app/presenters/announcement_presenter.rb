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

  def display_announcement_type
    case announcement
    when Speech
      if ["Written statement", "Oral statement"].include?(announcement.speech_type.name)
        "Statement to parliament"
      else
        "Speech"
      end
    when NewsArticle
      announcement.class.to_s.underscore.humanize
    else
      raise "Unexpected type: #{announcement.type}"
    end
  end
end
