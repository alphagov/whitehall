module WorldLocationHelper
  def group_and_sort(locations)
    locations
      .map { |location| [ActiveSupport::Inflector.transliterate(location.name_without_prefix), location] }
      .sort_by { |transliterated_name, _location| transliterated_name }
      .group_by { |transliterated_name, _location| transliterated_name.first.upcase }
      .sort
      .map { |(letter, names_and_locations)| [letter, names_and_locations.map { |_transliterated_name, location| location }] }
  end

  def sort(locations)
    locations
      .map { |location| [ActiveSupport::Inflector.transliterate(location.name_without_prefix), location] }
      .sort_by { |transliterated_name, _location| transliterated_name }
      .map { |_transliterated_name, location| location }
  end
end
