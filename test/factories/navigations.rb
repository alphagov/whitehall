FactoryBot.define do
  factory :navigation do
    sequence(:content_id) { SecureRandom.uuid }
  end
end
