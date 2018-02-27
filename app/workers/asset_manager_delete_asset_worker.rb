class AssetManagerDeleteAssetWorker < WorkerBase
  def perform(legacy_url_path)
    gds_api_response = asset_manager.whitehall_asset(legacy_url_path)
    asset_url = gds_api_response['id']
    asset_id = asset_url[/\/assets\/(.*)/, 1]

    asset_manager.delete_asset(asset_id)
  end

private

  def asset_manager
    Services.asset_manager
  end
end
