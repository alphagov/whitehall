module LocaleHelper
  def select_locale(attribute, locales, options = {})
    select_tag attribute, options_for_select(options_for_locales(locales)), options
  end

  def options_for_locales(locales)
    locales.map do |locale|
      locale = Locale.coerce(locale)
      [locale.native_and_english_language_name, locale.code.to_s]
    end
  end

  def options_for_foreign_language_locale(edition)
    options = [['Choose foreign language...', nil]] + options_for_locales(Locale.non_english)
    options_for_select(options, edition.non_english_edition? ? edition.locale : nil)
  end
end
