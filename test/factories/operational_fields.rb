FactoryBot.define do
  factory :operational_field do
    sequence(:name) { |index| "field-#{index}" }
    description "description of field"
  end
end
