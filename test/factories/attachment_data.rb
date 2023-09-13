FactoryBot.define do
  factory :attachment_data do
    file { File.open(Rails.root.join("test/fixtures/greenpaper.pdf")) }
    uploaded_to_asset_manager_at { Time.zone.now }
  end

  factory :attachment_data_with_assets, parent: :attachment_data do
    use_non_legacy_endpoints { true }

    after(:build) do |attachment_data|
      attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: "greenpaper.pdf")
      attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id_thumbnail", variant: Asset.variants[:thumbnail], filename: "thumbnail_greenpaper.pdf.png")
    end
  end

  factory :attachment_data_with_asset, class: AttachmentData do
    file { File.open(Rails.root.join("test/fixtures/sample.docx")) }
    uploaded_to_asset_manager_at { Time.zone.now }
    use_non_legacy_endpoints { true }

    after(:build) do |attachment_data|
      attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id", variant: Asset.variants[:original], filename: "sample.docx")
    end
  end

  factory :attachment_data_with_csv_asset, parent: :attachment_data do
    use_non_legacy_endpoints { true }
    file { File.open(Rails.root.join("test/fixtures/dft_statistical_data_set_sample.csv")) }
    after(:build) do |attachment_data|
      attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: "dft_statistical_data_set_sample.csv")
    end
  end

  factory :image_attachment_data, parent: :attachment_data do
    file { File.open(Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg")) }
  end
end
