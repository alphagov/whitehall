module Admin::LocaleHelper
  def options_for_locales(locales)
    locales.map do |locale|
      locale = Locale.coerce(locale)
      [locale.native_and_english_language_name, locale.code.to_s]
    end
  end
end
