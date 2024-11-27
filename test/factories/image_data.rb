FactoryBot.define do
  factory :generic_image_data, class: ImageData do
    file { image_fixture_file }

    trait(:jpg) do
      after(:build) do |image_data|
        image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: image_data.filename)
        image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s960", variant: Asset.variants[:s960], filename: "s960_#{image_data.filename}")
        image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s712", variant: Asset.variants[:s712], filename: "s712_#{image_data.filename}")
        image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s630", variant: Asset.variants[:s630], filename: "s630_#{image_data.filename}")
        image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s465", variant: Asset.variants[:s465], filename: "s465_#{image_data.filename}")
        image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s300", variant: Asset.variants[:s300], filename: "s300_#{image_data.filename}")
        image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s216", variant: Asset.variants[:s216], filename: "s216_#{image_data.filename}")
      end
    end

    trait(:svg) do
      file { File.open(Rails.root.join("test/fixtures/images/test-svg.svg")) }

      after(:build) do |image_data|
        image_data.assets << build(:asset, asset_manager_id: "asset_manager_id", variant: Asset.variants[:original], filename: image_data.filename)
      end
    end
  end

  factory :hero_image_data, class: ImageData do
    file { image_fixture_file }

    image_kind { "hero_desktop" }

    after(:build) do |image_data|
      image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: image_data.filename)
      variants = %W[#{image_data.image_kind}_2x #{image_data.image_kind}_1x]
      variants.each do |variant|
        image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_#{variant}", variant: Asset.variants[variant], filename: "#{variant}_#{image_data.filename}")
      end

      # Defining this method is a bit of a hack, but with FactoryBot created model,
      # the file_url method just returns nil, which makes it less useful for testing
      def image_data.file_url(variant)
        "http://asset-manager/#{variant}"
      end
    end
  end

  factory :image_data, parent: :generic_image_data, traits: [:jpg]
  factory :image_data_for_svg, parent: :generic_image_data, traits: [:svg]
  factory :image_data_with_no_assets, parent: :generic_image_data
end
