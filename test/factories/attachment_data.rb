FactoryBot.define do
  factory :attachment_data do
    file { File.open(Rails.root.join("test/fixtures/greenpaper.pdf")) }
    uploaded_to_asset_manager_at { Time.zone.now }
  end

  factory :attachment_data_with_assets, parent: :attachment_data do
    use_non_legacy_endpoints { true }

    after(:build) do |attachment_data|
      attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original])
      attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id_thumbnail", variant: Asset.variants[:thumbnail])
    end
  end

  factory :attachment_data_with_asset, class: AttachmentData do
    file { File.open(Rails.root.join("test/fixtures/sample.docx")) }
    uploaded_to_asset_manager_at { Time.zone.now }
    use_non_legacy_endpoints { true }

    after(:build) do |attachment_data|
      attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id", variant: Asset.variants[:original])
    end
  end

  factory :image_attachment_data, parent: :attachment_data do
    file { File.open(Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg")) }
  end
end
