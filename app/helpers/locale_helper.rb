module LocaleHelper
  def options_for_non_english_locales
    Locale.non_english.map do |l|
      ["#{l.native_language_name} (#{l.english_language_name})" , l.code]
    end
  end

  def select_locale(attribute, locales, options = {})
    select_tag attribute, options_for_select(options_for_locales(locales)), options
  end

  def options_for_locales(locales)
    locales.map {|l| ["#{l.native_language_name} (#{l.english_language_name})", l.code.to_s] }
  end
end
