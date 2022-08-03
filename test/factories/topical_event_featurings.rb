FactoryBot.define do
  factory :topical_event_featuring do
    association :edition, factory: :published_edition
    topical_event
    sequence(:ordering) { |index| index }
    association :image, factory: :topical_event_featuring_image_data
    alt_text { "An accessible description of the image" }
  end

  factory :offsite_topical_event_featuring, class: TopicalEventFeaturing do
    offsite_link
    topical_event
    sequence(:ordering) { |index| index }
    association :image, factory: :topical_event_featuring_image_data
    edition { nil }
    alt_text { "An accessible description of the image" }
  end
end
