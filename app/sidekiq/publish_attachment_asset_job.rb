class PublishAttachmentAssetJob < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)

    asset_attributes = {
      "draft" => false,
    }

    unless attachment_data.replaced?
      asset_attributes.merge!({ "parent_document_url" => attachment_data.attachable_url })
    end

    # We need to delete first, because if we delete after updating, and the delete request fails,
    # we will have a live asset. Asset Manager should let us update the deleted asset,
    # in line with recent changes that now permit the update of a deleted draft asset.
    # At this point in time, the asset is still in draft in Asset Manager, since the draft: false update
    # has not yet been sent, as we do not send it from anywhere else in the code.
    attachment_data.assets.each do |asset|
      AssetManager::AssetDeleter.call(asset.asset_manager_id) if attachment_data.deleted?
      AssetManager::AssetUpdater.call(asset.asset_manager_id, asset_attributes)
    end
  end
end
