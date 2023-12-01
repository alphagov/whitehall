class AssetManager::AssetUpdater
  include AssetManager::ServiceHelper

  class AssetAlreadyDeleted < StandardError
    def initialize(identifier, asset_data_id)
      super("Asset '#{identifier}' for Attachment Data #{asset_data_id} expected not to be deleted in Asset Manager")
    end
  end

  class AssetAttributesEmpty < StandardError
    def initialize(identifier, asset_data_id)
      super("Attempting to update '#{identifier}' for Attachment Data #{asset_data_id} with empty attachment attributes")
    end
  end

  def self.call(*args)
    new.call(*args)
  end

  def call(asset_manager_id, asset_data, new_attributes = {})
    update_with_asset_manager_id(asset_manager_id, asset_data, new_attributes)
  end

private

  def update_with_asset_manager_id(asset_manager_id, asset_data, new_attributes)
    raise AssetAttributesEmpty.new(asset_manager_id, asset_data.id) if new_attributes.empty?

    attributes = find_asset_by_id(asset_manager_id)
    asset_deleted = attributes["deleted"]

    if asset_deleted
      raise AssetAlreadyDeleted.new(asset_manager_id, asset_data.id)
    end

    keys = new_attributes.keys
    unless attributes.slice(*keys) == new_attributes.slice(*keys)
      asset_manager.update_asset(asset_manager_id, new_attributes)
    end
  end
end
