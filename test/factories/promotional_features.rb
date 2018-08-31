FactoryBot.define do
  factory :promotional_feature do
    association :organisation, factory: :executive_office
    title { 'Feature title' }
  end
end
