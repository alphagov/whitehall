class AssetManagerCreateAttachmentAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  # Carrierwave runs on an after_save hook and the transaction that inserts Assetable into the database
  # might not be committed yet. This can cause a race condition where the worker runs before the assetable is readable.
  # Use TransactionAwareClient for this worker to ensure that the commit is finished before the worker is executed.
  sidekiq_options queue: "asset_manager", client_class: Sidekiq::TransactionAwareClient

  def perform(temporary_location, asset_params, attachable_model_class, attachable_model_id, draft = false, auth_bypass_ids = [])
    return unless File.exist?(temporary_location)

    attachment_data = AttachmentData.where(id: asset_params["assetable_id"]).first

    return logger.info("Assetable AttachmentData of id #{asset_params['assetable_id']} does not exist") if attachment_data.nil?

    attachable = attachable_model_class.constantize.where(id: attachable_model_id).first
    if attachable.nil?
      return logger.info("Attachable #{attachable_model_class} of id #{attachable_model_id} does not exist")
    end

    file = File.open(temporary_location)

    asset_options = { file:, auth_bypass_ids:, draft: }
    if attachable.respond_to?(:access_limited?) && attachable.access_limited?
      asset_options[:access_limited_organisation_ids] = AssetManagerAccessLimitation.for(attachable)
    end

    response = create_asset(asset_options)

    file.close
    FileUtils.rm(file)
    FileUtils.rmdir(File.dirname(file))

    asset = attachment_data.assets.where(variant: asset_params["asset_variant"]).first_or_initialize
    asset.asset_manager_id = response.asset_manager_id
    asset.filename = response.filename
    asset.save!

    if attachable.is_a?(Edition)
      PublishingApiDraftUpdateWorker.perform_async(attachable.class.to_s, attachable.id)
    else
      AssetManagerAttachmentMetadataWorker.perform_async(attachment_data.id)
    end
  end
end
