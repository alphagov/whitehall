FactoryBot.define do
  trait :translated do
    transient do
      translated_into { nil }
    end

    after(:build) do |object, evaluator|
      if evaluator.translated_into
        extra_translations =
          case evaluator.translated_into
          when Hash
            evaluator.translated_into
          when Array
            evaluator.translated_into.inject({}) { |trans, locale| trans[locale] = {}; trans }
          else
            { evaluator.translated_into => {} }
          end
        extra_translations.each do |(locale, locale_attributes)|
          locale_attributes ||= {}
          object.class.translated_attribute_names.each do |attribute|
            if object.read_attribute(attribute).present?
              locale_attributes[attribute] ||= "#{locale}-#{object.read_attribute(attribute)}"
            end
          end
          locale_attributes.each do |attribute, value|
            object.write_attribute(attribute, value, locale: locale)
          end
        end
      end
    end
  end
end
