class AssetManagerCreateWhitehallAssetWorker < WorkerBase
  include AssetManager::ServiceHelper

  sidekiq_options queue: "asset_manager"

  def perform(file_path, legacy_url_path, model_id = nil, asset_version = nil, draft = false, attachable_model_class = nil, attachable_model_id = nil, auth_bypass_ids = [])
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

    response = asset_manager.create_whitehall_asset(asset_options)

    create_asset_manager_asset(model_id, asset_version, response)

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

private

  def create_asset_manager_asset(model_id, asset_version, response)
    return unless model_id && asset_version

    response_id = get_asset_id(response)
    save_asset_id_to_assets(model_id, asset_version, response_id)
  end

  def get_asset_id(response)
    attributes = response.to_hash
    url = attributes["id"]
    url[/\/assets\/(.*)/, 1]
  end

  def save_asset_id_to_assets(model_id, version, asset_manager_id)
    asset = Asset.new(asset_manager_id:, attachment_data_id: model_id, version:)
    asset.save!
  end
end
