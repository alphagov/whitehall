FactoryBot.define do
  factory :classification_featuring do
    association :edition, factory: :published_edition
    classification
    sequence(:ordering) { |index| index }
    association :image, factory: :classification_featuring_image_data
    alt_text { "An accessible description of the image" }
  end

  factory :offsite_classification_featuring, class: ClassificationFeaturing do
    classification
    sequence(:ordering) { |index| index }
    association :image, factory: :classification_featuring_image_data
    edition { nil }
    alt_text { "An accessible description of the image" }
  end
end
