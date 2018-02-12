class AssetManagerUpdateAssetWorker < WorkerBase
  def perform(legacy_url_path, attributes = {})
    gds_api_response = Services.asset_manager.whitehall_asset(legacy_url_path)
    unless gds_api_response['draft'] == attributes['draft']
      asset_url = gds_api_response['id']
      asset_id = asset_url[/\/assets\/(.*)/, 1]
      Services.asset_manager.update_asset(asset_id, attributes)
    end
  end
end
