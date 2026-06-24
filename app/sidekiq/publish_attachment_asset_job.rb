class PublishAttachmentAssetJob < JobBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id, assetable_type = "AttachmentData")
    asset_data = assetable_type.constantize.find(attachment_data_id)

    asset_attributes = {
      "draft" => false,
    }

    if asset_data.last_attachable.respond_to?(:public_url)
      asset_attributes.merge!({ "parent_document_url" => asset_data.last_attachable.public_url })
    end

    # We need to delete the asset first, because if we delete it after updating the draft value to false, and the delete request fails,
    # the asset will remain live.
    asset_data.assets.each do |asset|
      AssetManager::AssetDeleter.call(asset.asset_manager_id) if asset_data.deleted?
      AssetManager::AssetUpdater.call(asset.asset_manager_id, asset_attributes) if asset_data.needs_publishing?
    end
  end
end
