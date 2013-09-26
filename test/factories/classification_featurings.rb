FactoryGirl.define do
  factory :classification_featuring do
    association :edition, factory: :published_edition
    classification
    sequence(:ordering) { |index| index }
    association :image, factory: :classification_featuring_image_data
    alt_text "An accessible description of the image"
  end
end
