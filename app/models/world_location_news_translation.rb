class WorldLocationNewsTranslation
  attr_accessor :translated_locales

  def initialize(translated_locales = [])
    @translated_locales = Array(translated_locales)
  end

  def available_in_multiple_languages?
    translated_locales.count > 1
  end
end
