FactoryBot.define do
  factory :generic_featured_image_data, class: FeaturedImageData do
    file { image_fixture_file }
    featured_imageable { build(:worldwide_organisation) }

    trait(:jpg) do
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

  factory :featured_image_data, parent: :generic_featured_image_data, traits: [:jpg]
  factory :featured_image_data_with_no_assets, parent: :generic_featured_image_data
end
