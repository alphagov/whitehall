class PublishAttachmentAssetJob < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)

    asset_attributes = {
      "draft" => false,
    }

    if attachment_data.last_attachable.respond_to?(:public_url)
      asset_attributes.merge!({ "parent_document_url" => attachment_data.last_attachable.public_url })
    end

    # We need to delete the asset first, because if we delete it after updating the draft value to false, and the delete request fails,
    # the asset will remain live.
    attachment_data.assets.each do |asset|
      AssetManager::AssetDeleter.call(asset.asset_manager_id) if attachment_data.deleted?
      AssetManager::AssetUpdater.call(asset.asset_manager_id, asset_attributes) if attachment_data.needs_publishing?
    end
  end
end
