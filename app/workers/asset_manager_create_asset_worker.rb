class AssetManagerCreateAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  sidekiq_options queue: "asset_manager"

  def perform(temporary_location, asset_params, draft = false, attachable_model_class = nil, attachable_model_id = nil, auth_bypass_ids = [])
    return unless File.exist?(temporary_location)

    file = File.open(temporary_location)

    assetable_id, assetable_type, asset_variant = asset_params.values_at("assetable_id", "assetable_type", "asset_variant")
    asset_options = { file:, auth_bypass_ids:, draft: }
    authorised_organisation_uids = get_authorised_organisation_ids(attachable_model_class, attachable_model_id)
    asset_options[:access_limited_organisation_ids] = authorised_organisation_uids if authorised_organisation_uids

    response = asset_manager.create_asset(asset_options)
    asset_manager_id = get_asset_id(response)
    filename = get_filename(response)
    save_asset(assetable_id, assetable_type, asset_variant, asset_manager_id, filename)

    perform_draft_update(attachable_model_class, attachable_model_id)

    file.close
    FileUtils.rm(file)
    FileUtils.rmdir(File.dirname(file))
  end

private

  def perform_draft_update(attachable_model_class, attachable_model_id)
    if attachable_model_class && attachable_model_id && attachable_model_class.constantize.ancestors.include?(Edition)
      attachable = attachable_model_class.constantize.find(attachable_model_id)
      draft_updater = Whitehall.edition_services.draft_updater(attachable)

      draft_updater.perform!
    end
  end

  def get_authorised_organisation_ids(attachable_model_class, attachable_model_id)
    if attachable_model_class && attachable_model_id
      attachable_model = attachable_model_class.constantize.find(attachable_model_id)
      if attachable_model.respond_to?(:access_limited?) && attachable_model.access_limited?
        AssetManagerAccessLimitation.for(attachable_model)
      end
    end
  end

  def save_asset(assetable_id, assetable_type, variant, asset_manager_id, filename)
    Asset.create!(asset_manager_id:, assetable_id:, assetable_type:, variant:, filename:)
  end

  def get_asset_id(response)
    attributes = response.to_hash
    url = attributes["id"]
    url[/\/assets\/(.*)/, 1]
  end

  def get_filename(response)
    attributes = response.to_hash
    attributes["name"]
  end
end
