FactoryBot.define do
  factory :topical_event_featuring_image_data do
    file { image_fixture_file }

    after(:build) do |topical_event_featuring_image_data|
      topical_event_featuring_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: topical_event_featuring_image_data.filename)
      topical_event_featuring_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s960", variant: Asset.variants[:s960], filename: "s960_#{topical_event_featuring_image_data.filename}")
      topical_event_featuring_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s712", variant: Asset.variants[:s712], filename: "s712_#{topical_event_featuring_image_data.filename}")
      topical_event_featuring_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s630", variant: Asset.variants[:s630], filename: "s630_#{topical_event_featuring_image_data.filename}")
      topical_event_featuring_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s465", variant: Asset.variants[:s465], filename: "s465_#{topical_event_featuring_image_data.filename}")
      topical_event_featuring_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s300", variant: Asset.variants[:s300], filename: "s300_#{topical_event_featuring_image_data.filename}")
      topical_event_featuring_image_data.assets << build(:asset, asset_manager_id: "asset_manager_id_s216", variant: Asset.variants[:s216], filename: "s216_#{topical_event_featuring_image_data.filename}")
    end
  end
end
