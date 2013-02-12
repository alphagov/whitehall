class LocalisedModel < BasicObject
  attr_reader :fixed_locale

  def initialize(model, locale)
    @model = model
    @fixed_locale = locale
  end

  def method_missing(method, *args, &block)
    ::I18n.with_locale @fixed_locale do
      @model.__send__ method, *args, &block
    end
  end
end
