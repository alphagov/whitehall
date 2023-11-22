FactoryBot.define do
  factory :featured_image_data do
    file { image_fixture_file }
    featured_imageable { build(:topical_event) }

    after(:build) do |featured_image_data|
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: featured_image_data.filename)
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s960", variant: Asset.variants[:s960], filename: "s960_#{featured_image_data.filename}")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s712", variant: Asset.variants[:s712], filename: "s712_#{featured_image_data.filename}")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s630", variant: Asset.variants[:s630], filename: "s630_#{featured_image_data.filename}")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s465", variant: Asset.variants[:s465], filename: "s465_#{featured_image_data.filename}")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s300", variant: Asset.variants[:s300], filename: "s300_#{featured_image_data.filename}")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s216", variant: Asset.variants[:s216], filename: "s216_#{featured_image_data.filename}")
    end
  end
end
