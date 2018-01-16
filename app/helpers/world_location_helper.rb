module WorldLocationHelper
  def group_and_sort(locations)
    locations.
      # transliterate name for sorting once, we're going to use it twice:
      map { |location| [ActiveSupport::Inflector.transliterate(location.name_without_prefix), location] }.
      # ... 1. to sort (to avoid Côt coming after Cow) ...
      sort_by { |transliterated_name, _location| transliterated_name }.
      # ... 2. to group by the first letter (to avoid Éire not being in E)...
      group_by { |transliterated_name, _location| transliterated_name.first.upcase }.
      # then we sort the structure by the first letters
      sort.
      # finally we remove the sorted name from the structure
      map { |(letter, names_and_locations)| [letter, names_and_locations.map { |_transliterated_name, location| location }] }
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
