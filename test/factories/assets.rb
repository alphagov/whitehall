FactoryBot.define do
  factory :asset do
    variant { Asset.variants[:original] }
    asset_manager_id { "asset_manager_id" }
    filename { "filename" }
  end
end
