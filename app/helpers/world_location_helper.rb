module WorldLocationHelper
  def sort(locations)
    locations
      .map { |location| [ActiveSupport::Inflector.transliterate(location.name_without_prefix), location] }
      .sort_by { |transliterated_name, _location| transliterated_name.downcase }
      .map { |_transliterated_name, location| location }
  end
end
