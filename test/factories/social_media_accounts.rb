FactoryBot.define do
  factory :social_media_account do
    social_media_service
    url { "http://example.com" }
  end
end
