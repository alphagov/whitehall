class AssetManagerCreateWhitehallAssetWorker < WorkerBase
  include AssetManagerWorkerHelper

  def perform(file_path, legacy_url_path, draft = false, model_class = nil, model_id = nil)
    return unless File.exist?(file_path)

    file = File.open(file_path)
    asset_options = { file: file, legacy_url_path: legacy_url_path }
    asset_options[:draft] = true if draft

    if model_class && model_id
      model = model_class.constantize.find(model_id)
      if model.respond_to?(:access_limited?)
        if model.access_limited?
          authorised_user_uids = AssetManagerAccessLimitation.for(model)
          asset_options[:access_limited] = authorised_user_uids
        end
      end
    end

    asset_manager.create_whitehall_asset(asset_options)
    FileUtils.rm(file)
    FileUtils.rmdir(File.dirname(file))
  end
end
