class AssetManagerCreateWhitehallAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  sidekiq_options queue: "asset_manager"

  def perform(file_path, legacy_url_path, draft = false, attachable_model_class = nil, attachable_model_id = nil, auth_bypass_ids = [])
    return unless File.exist?(file_path)

    file = File.open(file_path)
    asset_options = { file:, legacy_url_path:, auth_bypass_ids: }
    asset_options[:draft] = true if draft

    if attachable_model_class && attachable_model_id
      attachable_model = attachable_model_class.constantize.find(attachable_model_id)
      if attachable_model.respond_to?(:access_limited?) && attachable_model.access_limited?
        organisation_ids = AssetManagerAccessLimitation.for(attachable_model)
        asset_options[:access_limited_organisation_ids] = organisation_ids
      end
    end

    asset_manager.create_whitehall_asset(asset_options)

    if attachable_model
      # The AttachmentData we want to set the timestamp on may not
      # exist yet, so create a worker to do it after a very short
      # delay.  The worker will retry if it still doesn't exist.
      AssetManagerAttachmentSetUploadedToWorker.perform_in(
        0.5.seconds, attachable_model_class, attachable_model_id, legacy_url_path
      )
    end

    file.close
    FileUtils.rm(file)
    FileUtils.rmdir(File.dirname(file))
  end
end
