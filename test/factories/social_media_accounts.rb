FactoryBot.define do
  factory :social_media_account, traits: [:translated] do
    social_media_service
    sequence("url") { |i| "https://www.social-#{i}.gov.uk" }
    sequence("title") { |i| "Social Media Account #{i}" }
  end
end
