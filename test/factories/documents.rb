FactoryBot.define do
  factory :document do
    document_type { "Unspecified" }
    sequence(:content_id) { SecureRandom.uuid }
  end
end
