class LocalisedModel < BasicObject
  attr_reader :fixed_locale

  def initialize(model, locale)
    @model = model
    @fixed_locale = locale
  end

  def method_missing(method, *args, &block)
    original_locale = ::I18n.locale
    ::I18n.locale = fixed_locale
    @model.__send__ method, *args, &block
  ensure
    ::I18n.locale = original_locale
  end
end
