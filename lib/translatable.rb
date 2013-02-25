module Translatable
  def remove_translations_for(locale)
    translations.where(locale: locale).each { |t| t.destroy }
  end
end
