FactoryBot.define do
  factory :topical_event do
    sequence(:name) { |index| "topical-event-#{index}" }
    summary { "Topical event summary" }
    description { "Topical event description" }
    block_content { { "body" => "Topical event body" } }

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
        service = SocialMediaService.find_by(name: "Twitter") || build(:social_media_service, name: "Twitter")
        topical_event.social_media_accounts << build(:social_media_account, social_media_service: service)
      end
    end
  end
end
