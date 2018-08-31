FactoryBot.define do
  factory :promotional_feature_link do
    association :promotional_feature_item
    url         { 'http://example.com' }
    text        { 'Link text' }
  end
end
