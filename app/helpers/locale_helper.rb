module LocaleHelper
  def select_locale(attribute, locales, options = {})
    select_tag attribute, options_for_select(options_for_locales(locales)), options
  end

  def options_for_locales(locales)
    locales.map { |l| ["#{l.native_language_name} (#{l.english_language_name})", l.code.to_s] }
  end
end
