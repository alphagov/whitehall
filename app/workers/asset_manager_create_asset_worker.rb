class AssetManagerCreateAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  sidekiq_options queue: "asset_manager"

  def perform(temporary_location, model_id = nil, asset_variant = nil, draft = false, attachable_model_class, attachable_model_id, auth_bypass_ids)

  end
end