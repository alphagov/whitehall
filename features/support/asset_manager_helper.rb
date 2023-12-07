require_relative "mocha"

Before do
  asset_manager = stub_everything("asset-manager")
  non_legacy_asset_details = { "id" => "http://asset-manager/assets/asset-id", "name" => "filename.pdf" }
  asset_manager.stubs(:create_asset).returns(non_legacy_asset_details)
  asset_manager.stubs(:asset).returns(non_legacy_asset_details)

  Services.stubs(:asset_manager).returns(asset_manager)
end
