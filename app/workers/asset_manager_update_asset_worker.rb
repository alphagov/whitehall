class AssetManagerUpdateAssetWorker < WorkerBase
  def perform(legacy_url_path, new_attributes = {})
    attributes = asset_manager.whitehall_asset(legacy_url_path).to_hash
    keys = new_attributes.keys
    unless attributes.slice(*keys) == new_attributes.slice(*keys)
      asset_url = attributes['id']
      asset_id = asset_url[/\/assets\/(.*)/, 1]
      asset_manager.update_asset(asset_id, new_attributes)
    end
  end

private

  def asset_manager
    Services.asset_manager
  end
end
