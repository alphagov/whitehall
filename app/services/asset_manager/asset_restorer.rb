class AssetManager::AssetRestorer
  include AssetManager::ServiceHelper

  def self.call(*args)
    new.call(*args)
  end

  # We can't undo a deletion via AssetManager::AssetUpdater (PATCH /assets/:id):
  # Asset Manager's own #update action looks assets up via
  # `Asset.undeleted.or(Asset.where(draft: true))`, so a deleted, non-draft
  # (live) asset can't even be found by that endpoint - it 404s before any
  # attributes are considered. `deleted_at` also isn't a permitted attribute
  # on that endpoint regardless. Restoring requires the dedicated
  # POST /assets/:id/restore action instead, which is the only one that both
  # looks up deleted assets and is allowed to touch deleted_at.
  def call(asset_manager_id)
    attributes = find_asset_by_id(asset_manager_id)
    return unless attributes["deleted"]

    asset_manager.restore_asset(asset_manager_id)
  end
end
