class AssetManagerCreateAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  # Carrierwave runs on an after_save hook and the transaction that inserts Assetable into the database
  # might not be committed yet. This can cause a race condition where the worker runs before the assetable is readable.
  # Use TransactionAwareClient for this worker to ensure that the commit is finished before the worker is executed.
  sidekiq_options queue: "asset_manager", client_class: Sidekiq::TransactionAwareClient

  def perform(temporary_location, asset_params, auth_bypass_ids = [])
    return unless File.exist?(temporary_location)

    assetable_id, assetable_type, asset_variant = asset_params.values_at("assetable_id", "assetable_type", "asset_variant")
    assetable = assetable_type.constantize.where(id: assetable_id).first

    return logger.info("Assetable #{assetable_type} of id #{assetable_id} does not exist") if assetable.nil?

    file = File.open(temporary_location)
    response = create_asset({ file:, auth_bypass_ids:, draft: false })
    file.close
    FileUtils.rm(file)
    FileUtils.rmdir(File.dirname(file))

    asset = assetable.assets.where(variant: asset_variant).first_or_initialize
    asset.asset_manager_id = response.asset_manager_id
    asset.filename = response.filename
    asset.save!

    assetable.republish_on_assets_ready if assetable.respond_to? :republish_on_assets_ready
  end
end
