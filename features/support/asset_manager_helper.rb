Before do
  Services.stubs(:asset_manager).returns(stub_everything('asset-manager'))
  AssetManagerUpdateAssetWorker.stubs(:perform_async)
end
