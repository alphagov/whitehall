FactoryBot.define do
  factory :promotional_feature_item do
    association :promotional_feature
    summary { 'Summary text' }
    image { image_fixture_file }
    image_alt_text { "Image alt text" }
  end
end
