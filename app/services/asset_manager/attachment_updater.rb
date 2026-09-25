class AssetManager::AttachmentUpdater
  # Runs whenever Whitehall considers an attachment_data live (i.e. not
  # attachment_data.deleted? - the significant attachment's own `deleted`
  # flag, not to be confused with Asset Manager's deleted_at on the
  # underlying asset). This keeps every asset under it in sync with that
  # view, including restoring one that Asset Manager still has marked
  # deleted but Whitehall does not: historically, an attachment being
  # soft-deleted on *any* draft of a document, while nothing else was
  # publicly visible, could delete every asset under its attachment_data in
  # Asset Manager - even after Whitehall's own view moved on. Nothing ever
  # called Asset Manager's restore endpoint to undo that, so the mismatch
  # was permanent (see AssetManager::AssetRestorer for the fix, and
  # PublishAttachmentAssetJob for the *intentional* delete-on-publish path,
  # which this doesn't touch).
  def self.call(attachment_data)
    return if attachment_data.deleted?

    asset_attributes = {
      "access_limited_organisation_ids" => attachment_data.access_limitation_organisation_ids,
      "access_limited_user_ids" => attachment_data.access_limitation_individual_ids,
      "draft" => attachment_data.draft? && !(attachment_data.replaced? || attachment_data.unpublished?),
    }

    unless attachment_data.replaced?
      asset_attributes.merge!({ "parent_document_url" => attachment_data.attachable_url })
    end

    attachment_data.assets.each do |asset|
      AssetManager::AssetRestorer.call(asset.asset_manager_id)
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
