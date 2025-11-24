FactoryBot.define do
  factory :document do
    document_type { "Unspecified" }
    sequence(:content_id) { SecureRandom.uuid }
    sequence(:slug) { |index| "slug-#{index}" }
  end
end
