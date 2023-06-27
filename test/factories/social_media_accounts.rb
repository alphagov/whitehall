FactoryBot.define do
  factory :social_media_account, traits: [:translated] do
    social_media_service
    url { "http://example.com" }
  end
end
