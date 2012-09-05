module AnnouncementsHelper
  def announcement_type(announcement)
    if announcement.type == 'NewsArticle'
      announcement.class.to_s.underscore.humanize
    else
      if ["Written statement", "Oral statement"].include?(announcement.speech_type.name)
        "Statement to parliament"
      else
        "Speech"
      end
    end
  end

  def announcement_row_number
    @announcement_row_number ||= 0
    @announcement_row_number += 1
  end
end
