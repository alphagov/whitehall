class LocalisedModel < BasicObject
  attr_reader :fixed_locale

  def initialize(model, locale, associations = [])
    @model = model
    @fixed_locale = locale
    @associations_to_localise = Array(associations)
    @model.instance_variable_set(:@errors, ::ErrorsInEnglish.new(@model))
  end

  def method_missing(method, *args, &block)
    ::I18n.with_locale @fixed_locale do
      response = @model.__send__(method, *args, &block)

      # Automatically localise any ActiveRecord associations
      if translatable_association?(method, response)
        response = localise_association(method, response)
      end

      response
    end
  end

  # Rails calls this a lot in form builder code. By default #to_model will
  # revert our localised model back to the standard model, so we override it
  # to get the behaviour we want.
  def to_model
    self
  end

private
  def translatable_association?(method, response)
    return false unless @model.class.respond_to?(:reflect_on_association)

    association = @model.class.reflect_on_association(method)
    return false if association.nil?

    return false unless @associations_to_localise.include?(method)

    association_class = association.collection? ? association.class_name.constantize : response.class
    association_class.respond_to?(:translates?) && association_class.translates?
  end

  def localise_association(method, response)
    association = @model.class.reflect_on_association(method)

    if association.collection?
      # Converting to an array early isn't ideal, but Rails expects this to be
      # array-like throughout the form builder code and will just reload the
      # collection from scratch if it doesn't behave like one.
      response.map { |r| ::LocalisedModel.new(r, @fixed_locale) }
    else
      ::LocalisedModel.new(response, @fixed_locale)
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
