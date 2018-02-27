class AssetManagerDeleteAssetWorker < WorkerBase
  include AssetManagerWorkerHelper

  def perform(legacy_url_path)
    attributes = asset_manager.whitehall_asset(legacy_url_path).to_hash
    asset_url = attributes['id']
    asset_id = asset_url[/\/assets\/(.*)/, 1]

    asset_manager.delete_asset(asset_id)
  end
end
