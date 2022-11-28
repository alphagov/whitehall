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
end
