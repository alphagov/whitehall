class AssetManagerDeleteAssetWorker < WorkerBase
  def perform(legacy_url_path)
    gds_api_response = Services.asset_manager.whitehall_asset(legacy_url_path)
    asset_url = gds_api_response['id']
    asset_id = asset_url[/\/assets\/(.*)/, 1]

    Services.asset_manager.delete_asset(asset_id)
  end
end
