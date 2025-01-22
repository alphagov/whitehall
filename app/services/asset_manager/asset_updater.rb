class AssetManager::AssetUpdater
  include AssetManager::ServiceHelper

  class AssetAttributesEmpty < StandardError
    def initialize(asset_manager_id)
      super("Attempting to update Asset with asset_manager_id: '#{asset_manager_id}' with empty attachment attributes")
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

    keys = new_attributes.keys
    unless attributes.slice(*keys) == new_attributes.slice(*keys)
      asset_manager.update_asset(asset_manager_id, new_attributes)
    end
  end
end
