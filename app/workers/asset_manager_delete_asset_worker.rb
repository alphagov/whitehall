class AssetManagerDeleteAssetWorker < WorkerBase
  include AssetManagerWorkerHelper

  def perform(legacy_url_path)
    attributes = find_asset_by(legacy_url_path)
    asset_manager.delete_asset(attributes['id'])
  end
end
