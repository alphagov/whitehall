class AssetManager::AttachmentUpdater
  def self.call(attachment_data)
    return if attachment_data.deleted?

    asset_attributes = {
      "access_limited_organisation_ids" => attachment_data.access_limitation,
      "draft" => attachment_data.draft? && !(attachment_data.replaced? || attachment_data.unpublished?),
    }

    unless attachment_data.replaced?
      asset_attributes.merge!({ "parent_document_url" => attachment_data.attachable_url })
    end

    attachment_data.assets.each do |asset|
      AssetManager::AssetUpdater.call(asset.asset_manager_id, asset_attributes)
    end
  end

  def self.replace(attachment_data)
    return if attachment_data.deleted? || !attachment_data.replaced?

    attachment_data.assets.each do |asset|
      replacement_id = attachment_data.replacement_asset_for(asset)&.asset_manager_id

      next if replacement_id.nil?

      AssetManager::AssetUpdater.call(asset.asset_manager_id, { "replacement_id" => replacement_id })
    end
  end
end
