class AssetManagerCreateAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  # Carrierwave runs on an after_save hook and the transaction that inserts Assetable into the database
  # might not be committed yet. This can cause a race condition where the worker runs before the assetable is readable.
  # Use TransactionAwareClient for this worker to ensure that the commit is finished before the worker is executed.
  sidekiq_options queue: "asset_manager", client_class: Sidekiq::TransactionAwareClient

  def perform(temporary_location, asset_params, draft = false, attachable_model_class = nil, attachable_model_id = nil, auth_bypass_ids = [])
    return unless File.exist?(temporary_location)

    file = File.open(temporary_location)

    assetable_id, assetable_type, asset_variant = asset_params.values_at("assetable_id", "assetable_type", "asset_variant")

    return logger.info("Assetable #{assetable_type} of id #{assetable_id} does not exist") unless assetable_type.constantize.where(id: assetable_id).exists?

    asset_options = { file:, auth_bypass_ids:, draft: }
    authorised_organisation_uids = get_authorised_organisation_ids(attachable_model_class, attachable_model_id)
    asset_options[:access_limited_organisation_ids] = authorised_organisation_uids if authorised_organisation_uids

    create_asset(asset_options, asset_variant, assetable_id, assetable_type)

    enqueue_downstream_service_updates(assetable_id, assetable_type, attachable_model_class, attachable_model_id)

    file.close
    FileUtils.rm(file)
    FileUtils.rmdir(File.dirname(file))
  end

private

  def create_asset(asset_options, asset_variant, assetable_id, assetable_type)
    response = asset_manager.create_asset(asset_options)
    asset_manager_id = get_asset_id(response)
    filename = get_filename(response)
    save_asset(assetable_id, assetable_type, asset_variant, asset_manager_id, filename)
  end

  def enqueue_downstream_service_updates(assetable_id, assetable_type, attachable_model_class, attachable_model_id)
    assetable = assetable_type.constantize.find(assetable_id)
    assetable.republish_on_assets_ready if assetable.respond_to? :republish_on_assets_ready

    if attachable_model_class
      if attachable_model_class.constantize.ancestors.include?(Edition)
        PublishingApiDraftUpdateWorker.perform_async(attachable_model_class, attachable_model_id)
      else
        AssetManagerAttachmentMetadataWorker.perform_async(assetable_id)
      end
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
    asset = Asset.where(assetable_id:, assetable_type:, variant:).first_or_initialize
    asset.asset_manager_id = asset_manager_id
    asset.filename = filename
    asset.save!
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
