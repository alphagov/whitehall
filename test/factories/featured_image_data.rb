FactoryBot.define do
  factory :featured_image_data do
    file { image_fixture_file }

    after(:build) do |featured_image_data|
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: "minister-of-funk.960x640.jpg")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s960", variant: Asset.variants[:s960], filename: "s960_minister-of-funk.960x640.jpg")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s712", variant: Asset.variants[:s712], filename: "s712_minister-of-funk.960x640.jpg")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s630", variant: Asset.variants[:s630], filename: "s630_minister-of-funk.960x640.jpg")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s465", variant: Asset.variants[:s465], filename: "s465_minister-of-funk.960x640.jpg")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s300", variant: Asset.variants[:s300], filename: "s300_minister-of-funk.960x640.jpg")
      featured_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s216", variant: Asset.variants[:s216], filename: "s216_minister-of-funk.960x640.jpg")
    end
  end
end
