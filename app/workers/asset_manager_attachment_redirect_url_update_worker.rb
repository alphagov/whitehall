class AssetManagerAttachmentRedirectUrlUpdateWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return if attachment_data.blank? || attachment_data.deleted?

    attachment_data.assets.each do |asset|
      AssetManager::AssetUpdater.call(asset.asset_manager_id, { "redirect_url" => attachment_data.redirect_url })
    end
  end
end
