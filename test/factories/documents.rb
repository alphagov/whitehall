FactoryBot.define do
  factory :document do
    sequence(:content_id) { SecureRandom.uuid }
    sequence(:slug) { |index| "slug-#{index}" }
  end
end
