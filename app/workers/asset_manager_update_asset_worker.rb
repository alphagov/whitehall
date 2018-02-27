class AssetManagerUpdateAssetWorker < WorkerBase
  def perform(legacy_url_path, new_attributes = {})
    asset_manager = Services.asset_manager
    gds_api_response = asset_manager.whitehall_asset(legacy_url_path).to_hash
    keys = new_attributes.keys
    unless gds_api_response.slice(*keys) == new_attributes.slice(*keys)
      asset_url = gds_api_response['id']
      asset_id = asset_url[/\/assets\/(.*)/, 1]
      Services.asset_manager.update_asset(asset_id, new_attributes)
    end
  end
end
