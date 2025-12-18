class AssetManager::AssetUpdater
  include AssetManager::ServiceHelper

  class AssetAttributesEmpty < StandardError
    def initialize(asset_manager_id)
      super("Attempting to update Asset with asset_manager_id: '#{asset_manager_id}' with empty attachment attributes")
    end
  end

  class AssetDeleted < StandardError
    def initialize(asset_manager_id)
      super("Attempting to update Asset with asset_manager_id: '#{asset_manager_id}' that is live and deleted")
    end
  end

  def self.call(*args)
    new.call(*args)
  end

  def call(asset_manager_id, new_attributes)
    update_with_asset_manager_id(asset_manager_id, new_attributes)
  end

private

  def update_with_asset_manager_id(asset_manager_id, new_attributes)
    raise AssetAttributesEmpty, asset_manager_id if new_attributes.empty?

    attributes = find_asset_by_id(asset_manager_id)

    # We want to update draft assets that are marked as deleted. Currently, at the point of publishing the edition,
    # we run the deletion update via the `AssetDeleter` in `PublishAttachmentAssetJob`,
    # followed by an update of the draft status to `false` via the `AssetUpdater`.
    # This is particularly important for ensuring replacements work correctly when followed by a deletion.
    # Publishing the deleted state ensured that the original asset redirects to its deleted replacement, and thus 404s as well.

    # Asset Manager will raise a 404 when trying to fetch a deleted live asset for update. We raise here to make those cases explicit.
    raise AssetDeleted, asset_manager_id if attributes["deleted"] && !attributes["draft"]

    keys = new_attributes.keys
    unless attributes.slice(*keys) == new_attributes.slice(*keys)
      asset_manager.update_asset(asset_manager_id, new_attributes)
    end
  end
end
