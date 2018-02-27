class AssetManagerUpdateAssetWorker < WorkerBase
  include AssetManagerWorkerHelper

  def perform(legacy_url_path, new_attributes = {})
    attributes = find_asset_by(legacy_url_path)
    keys = new_attributes.keys
    unless attributes.slice(*keys) == new_attributes.slice(*keys)
      asset_manager.update_asset(attributes['id'], new_attributes)
    end
  end
end
