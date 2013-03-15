class LocalisedModel < BasicObject
  attr_reader :fixed_locale

  def initialize(model, locale)
    @model = model
    @fixed_locale = locale
    @model.instance_variable_set(:@errors, ::ErrorsInEnglish.new(@model))
  end

  def method_missing(method, *args, &block)
    ::I18n.with_locale @fixed_locale do
      @model.__send__ method, *args, &block
    end
  end
end

class ErrorsInEnglish < ::ActiveModel::Errors

  def generate_message(*args)
    ::I18n.with_locale(:en) do
      super
    end
  end
end
