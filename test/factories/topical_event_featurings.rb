FactoryBot.define do
  factory :topical_event_featuring do
    association :edition, factory: :published_edition
    topical_event
    sequence(:ordering) { |index| index }
    alt_text { "An accessible description of the image" }

    after(:build) do |featuring|
      featuring.image = build(:topical_event_featuring_image_data)
    end
  end

  factory :offsite_topical_event_featuring, class: TopicalEventFeaturing do
    offsite_link
    topical_event
    sequence(:ordering) { |index| index }
    edition { nil }
    alt_text { "An accessible description of the image" }

    after(:build) do |featuring|
      featuring.image = build(:topical_event_featuring_image_data)
    end
  end
end
