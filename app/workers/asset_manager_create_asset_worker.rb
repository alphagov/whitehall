class AssetManagerCreateAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  sidekiq_options queue: "asset_manager"

  def perform(temporary_location, asset_params, draft = false, attachable_model_class = nil, attachable_model_id = nil, auth_bypass_ids = [])
    return unless File.exist?(temporary_location)

    file = File.open(temporary_location)

    assetable_id, assetable_type, asset_variant, filename = asset_params.values_at("assetable_id", "assetable_type", "asset_variant", "filename")
    asset_options = { file:, auth_bypass_ids:, draft: }
    authorised_organisation_uids = get_authorised_organisation_ids(attachable_model_class, attachable_model_id)
    asset_options[:access_limited_organisation_ids] = authorised_organisation_uids if authorised_organisation_uids

    response = asset_manager.create_asset(asset_options)
    save_asset_id_to_assets(assetable_id, assetable_type, asset_variant, response, filename)

    if assetable_type == AttachmentData.name
      AttachmentData.find(assetable_id).uploaded_to_asset_manager!
    end

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

  def save_asset_id_to_assets(assetable_id, assetable_type, variant, response, filename)
    asset_manager_id = get_asset_id(response)
    derived_filename = get_filename(variant, filename)
    Asset.create!(asset_manager_id:, assetable_id:, assetable_type:, variant:, filename: derived_filename)
  end

  def get_asset_id(response)
    attributes = response.to_hash
    url = attributes["id"]
    url[/\/assets\/(.*)/, 1]
  end

  def get_filename(variant, filename)
    if variant == Asset.variants[:original]
      filename
    elsif variant == Asset.variants[:thumbnail]
      "thumbnail_#{filename}.png"
    else
      "#{variant}_#{filename}"
    end
  end
end
