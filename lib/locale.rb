class Locale
  def initialize(locale)
    @locale = locale
  end

  def native_language_name
    I18n.t("language_names.#{@locale}", locale: @locale)
  end
end

