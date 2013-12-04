module WorldLocationHelper

  def group_and_sort(locations)
    locations.sort_by(&:name_without_prefix).group_by {|location| location.name_without_prefix.first.upcase }.sort
  end

  def world_location_survey_url(location)
    case location.slug
    when "usa"
      "https://www.surveymonkey.com/s/873FC35"
    when "pakistan"
      case Locale.current.code
      when :en
        "https://www.surveymonkey.com/s/8VZC9G5"
      when :ur
        "https://www.surveymonkey.com/s/MVS53GS"
      end
    when "spain"
      case Locale.current.code
      when :en
        "https://www.surveymonkey.com/s/ML7GNTZ"
      when :es
        "https://www.surveymonkey.com/s/87WF3CC"
      end
    end
  end

end
