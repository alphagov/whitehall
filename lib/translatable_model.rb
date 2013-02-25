module TranslatableModel
  def non_english_translations
    translations.where(["locale != ?", I18n.default_locale])
  end

  def available_in_locale?(locale)
    translations.where(["locale = ?", locale]).exists?
  end

  def available_in_multiple_languages?
    translated_locales.length > 1
  end

  def remove_translations_for(locale)
    translations.where(locale: locale).each { |t| t.destroy }
  end
end
