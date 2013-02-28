module TranslatableModel
  def non_english_translations
    translations.where(["locale != ?", I18n.default_locale])
  end

  def available_in_locale?(locale)
    translations.where(["locale = ?", locale]).exists?
  end

  def available_in_multiple_languages?
    non_english_translated_locale_codes.any?
  end

  def remove_translations_for(locale)
    translations.where(locale: locale).each { |t| t.destroy }
  end

  def missing_translations
    non_english_translated_locales = non_english_translated_locale_codes.map { |l| Locale.new(l) }
    Locale.non_english - non_english_translated_locales
  end

  private

  def non_english_translated_locale_codes
    translated_locales - [:en]
  end
end
