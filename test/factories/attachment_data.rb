FactoryBot.define do
  factory :generic_attachment_data, class: AttachmentData do
    file { File.open(Rails.root.join("test/fixtures/greenpaper.pdf")) }

    trait(:pdf) do
      content_type { AttachmentUploader::PDF_CONTENT_TYPE }

      after(:build) do |attachment_data|
        attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: attachment_data.filename)
        attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id_thumbnail", variant: Asset.variants[:thumbnail], filename: "thumbnail_#{attachment_data.filename}.png")
      end
    end

    trait(:doc) do
      file { File.open(Rails.root.join("test/fixtures/sample.docx")) }

      after(:build) do |attachment_data|
        attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id", variant: Asset.variants[:original], filename: attachment_data.filename)
      end
    end

    trait(:csv) do
      file { File.open(Rails.root.join("test/fixtures/sample.csv")) }

      after(:build) do |attachment_data|
        attachment_data.assets << build(:asset, asset_manager_id: "asset_manager_id", variant: Asset.variants[:original], filename: attachment_data.filename)
      end
    end
  end

  factory :attachment_data, parent: :generic_attachment_data, traits: [:pdf]
  factory :attachment_data_with_asset, parent: :generic_attachment_data, traits: [:doc]
  factory :attachment_data_for_csv, parent: :generic_attachment_data, traits: [:csv]
  factory :attachment_data_with_no_assets, parent: :generic_attachment_data
end
