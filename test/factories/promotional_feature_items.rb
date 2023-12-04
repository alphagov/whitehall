FactoryBot.define do
  factory :generic_promotional_feature_item, class: PromotionalFeatureItem do
    association :promotional_feature
    summary { "Summary text" }

    trait(:with_image) do
      image { image_fixture_file }
      image_alt_text { "Image alt text" }

      after :build do |item|
        next if item.image.blank?

        filename = item.image.file.filename
        item.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename:)
        item.assets << build(:asset, asset_manager_id: "asset_manager_id_s960", variant: Asset.variants[:s960], filename: "s960_#{filename}")
        item.assets << build(:asset, asset_manager_id: "asset_manager_id_s712", variant: Asset.variants[:s712], filename: "s712_#{filename}")
        item.assets << build(:asset, asset_manager_id: "asset_manager_id_s630", variant: Asset.variants[:s630], filename: "s630_#{filename}")
        item.assets << build(:asset, asset_manager_id: "asset_manager_id_s465", variant: Asset.variants[:s465], filename: "s465_#{filename}")
        item.assets << build(:asset, asset_manager_id: "asset_manager_id_s300", variant: Asset.variants[:s300], filename: "s300_#{filename}")
        item.assets << build(:asset, asset_manager_id: "asset_manager_id_s216", variant: Asset.variants[:s216], filename: "s216_#{filename}")
      end
    end

    trait(:with_youtube_video_url) do
      youtube_video_url { "https://www.youtube.com/watch?v=fFmDQn9Lbl4" }
      youtube_video_alt_text { "YouTube alt text." }
    end
  end

  factory :promotional_feature_item, parent: :generic_promotional_feature_item, traits: [:with_image]
  factory :promotional_feature_item_with_youtube_video_url, parent: :generic_promotional_feature_item, traits: [:with_youtube_video_url]
end
