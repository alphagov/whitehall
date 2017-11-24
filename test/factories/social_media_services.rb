FactoryBot.define do
  factory :social_media_service do
    sequence(:name) { |n| "Social Media Service #{n}" }
  end
end
