class AssetManagerCreateAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  sidekiq_options queue: "asset_manager"

  def perform(temporary_location, asset_params, draft = false, attachable_model_class = nil, attachable_model_id = nil, auth_bypass_ids = [])
    return unless File.exist?(temporary_location)

    file = File.open(temporary_location)

    assetable_id, assetable_type, asset_variant = asset_params.values_at("assetable_id", "assetable_type", "asset_variant")
    asset_options = { file:, auth_bypass_ids:, draft: }
    authorised_user_uids = get_authorised_user_ids(attachable_model_class, attachable_model_id)
    asset_options[:access_limited] = authorised_user_uids if authorised_user_uids

    response = asset_manager.create_asset(asset_options)
    save_asset_id_to_assets(assetable_id, assetable_type, asset_variant, response)

    if assetable_type == AttachmentData.name && asset_variant == Asset.variants[:original]
      AttachmentData.find(assetable_id).uploaded_to_asset_manager!
    end

    file.close
    FileUtils.rm(file)
    FileUtils.rmdir(File.dirname(file))
  end

private

  def get_authorised_user_ids(attachable_model_class, attachable_model_id)
    if attachable_model_class && attachable_model_id
      attachable_model = attachable_model_class.constantize.find(attachable_model_id)
      if attachable_model.respond_to?(:access_limited?) && attachable_model.access_limited?
        AssetManagerAccessLimitation.for(attachable_model)
      end
    end
  end

  def save_asset_id_to_assets(assetable_id, assetable_type, variant, response)
    asset_manager_id = get_asset_id(response)
    Asset.create!(asset_manager_id:, assetable_id:, assetable_type:, variant:)
  end

  def get_asset_id(response)
    attributes = response.to_hash
    url = attributes["id"]
    url[/\/assets\/(.*)/, 1]
  end
end
