module LocaleHelper
  def options_for_non_english_locales
    Locale.non_english.map do |l|
      ["#{l.native_language_name} (#{l.english_language_name})" , l.code]
    end
  end
end
