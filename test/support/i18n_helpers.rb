module I18nHelpers
  def with_locale(locale)
    original_locale = I18n.locale
    I18n.locale = locale
    yield
  ensure
    I18n.locale = original_locale
  end
end
