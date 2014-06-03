FactoryGirl.define do
  trait :translated do
    ignore do
      translated_into nil
    end

    after(:build) do |object, evaluator|
      if evaluator.translated_into
        extra_translations =
          case evaluator.translated_into
          when Hash
            evaluator.translated_into
          when Array
	    evaluator.translated_into.reduce({}) { |trans, locale| trans[locale] = {}; trans }
          else
            {evaluator.translated_into => {}}
          end
        extra_translations.each do |(locale, locale_attributes)|
          locale_attributes ||= {}
          object.class.required_translated_attributes.each do |attribute|
            locale_attributes[attribute] ||= "#{locale}-#{object.read_attribute(attribute)}"
          end
          locale_attributes.each do |attribute, value|
            object.write_attribute(attribute, value, locale: locale)
          end
        end
      end
    end
  end
end
