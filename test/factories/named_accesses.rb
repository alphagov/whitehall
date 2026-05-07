FactoryBot.define do
  factory :named_access do
    association :edition
    email { generate(:email) }
  end
end
