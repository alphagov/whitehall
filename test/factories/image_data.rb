FactoryBot.define do
  factory :generic_image_data, class: ImageData do
    # File depends on the image kind, because carrierwave image validations which depend on image kind config run as soon
    # as the file attribute is set. So the order of the two lines below is important
    image_kind { "default" }
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

    trait(:missing_file) do
      file { nil }
    end
  end

  factory :image_data, parent: :generic_image_data, traits: [:jpg]
  factory :image_data_for_svg, parent: :generic_image_data, traits: [:svg]
  factory :image_data_with_no_assets, parent: :generic_image_data
  factory :image_data_with_missing_file, parent: :generic_image_data, traits: [:missing_file]
end
