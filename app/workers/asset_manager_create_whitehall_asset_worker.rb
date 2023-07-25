class AssetManagerCreateWhitehallAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  sidekiq_options queue: "asset_manager"

  WITH_TEMPORARY_ASSET_RELATED_PARAMS = 8
  EXPECTED_PARAMS = 6

  def perform(*args)
    # We eventually only run the code that is inside "perform_with_assets_params"
    # these changes are introduced to fix a prod issue that was caused by change in
    # arguments( decreased from 8 to 6 ) that were accepted by perform method
    # these cause one of the job that was about to execute just before application deployment
    # to fail. the changes are temporary.
    if args.length == EXPECTED_PARAMS
      perform_without_assets_params(*args)
    elsif args.length == WITH_TEMPORARY_ASSET_RELATED_PARAMS
      perform_with_assets_params(*args)
    else
      raise "invalid parameter count in sidekiq job"
    end
  end

  def perform_without_assets_params(file_path, legacy_url_path, draft = false, attachable_model_class = nil, attachable_model_id = nil, auth_bypass_ids = [])
    perform_with_assets_params(file_path, legacy_url_path, nil, nil, draft, attachable_model_class, attachable_model_id, auth_bypass_ids)
  end

  def perform_with_assets_params(file_path, legacy_url_path, _temp_asset_param = nil, _temp_another_asset_param = nil, draft = false, attachable_model_class = nil, attachable_model_id = nil, auth_bypass_ids = [])
    return unless File.exist?(file_path)

    file = File.open(file_path)
    asset_options = { file:, legacy_url_path:, auth_bypass_ids: }
    asset_options[:draft] = true if draft

    if attachable_model_class && attachable_model_id
      attachable_model = attachable_model_class.constantize.find(attachable_model_id)
      if attachable_model.respond_to?(:access_limited?) && attachable_model.access_limited?
        authorised_user_uids = AssetManagerAccessLimitation.for(attachable_model)
        asset_options[:access_limited] = authorised_user_uids
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
