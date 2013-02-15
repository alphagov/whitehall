FactoryGirl.define do
  trait :translated do
    ignore do
      translated_into nil
    end

    after(:build) do |object, evaluator|
      if evaluator.translated_into
        evaluator.translated_into.each do |locale|
          object.class.required_translated_attributes.each do |attribute|
            object.write_attribute(attribute, "#{locale}-#{object.read_attribute(attribute)}", locale: locale)
          end
        end
      end
    end
  end
end
