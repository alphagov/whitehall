module LocaleHelper
  def select_locale(attribute, locales, options = {})
    select_tag attribute, options_for_select(options_for_locales(locales)), options
  end

  def options_for_locales(locales)
    locales.map { |l| ["#{l.native_language_name} (#{l.english_language_name})", l.code.to_s] }
  end

  def options_for_foreign_language_locale(edition)
    options = [['Choose foreign language...', nil]] + options_for_locales(Locale.non_english)
    options_for_select(options, edition.non_english_edition? ? edition.locale : nil)
  end
end
