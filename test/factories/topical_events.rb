FactoryBot.define do
  factory :topical_event do
    sequence(:name) { |index| "topical-event-#{index}" }
    summary { "Topical event summary" }
    description { "Topical event description" }

    trait :active do
      start_date { Time.zone.today - 1.month }
      end_date { Time.zone.today + 1.month }
    end

    trait :with_logo do
      logo { build(:featured_image_data) }
      logo_alt_text { "Alternative text" }
    end

    trait :with_social_media_accounts do
      after :build do |topical_event|
        topical_event.social_media_accounts << build(:social_media_account)
      end
    end
  end
end
