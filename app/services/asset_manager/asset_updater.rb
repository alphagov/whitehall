class AssetManager::AssetUpdater
  include AssetManager::ServiceHelper

  class AssetAlreadyDeleted < StandardError
    def initialize(attachment_data_id, legacy_url_path)
      super("Asset '#{legacy_url_path}' for Attachment Data #{attachment_data_id} expected not to be deleted in Asset Manager")
    end
  end

  class AssetAttributesEmpty < StandardError
    def initialize(attachment_data_id, legacy_url_path)
      super("Attempting to update '#{legacy_url_path}' for Attachment Data #{attachment_data_id} with empty attachment attributes")
    end
  end

  def self.call(*args)
    new.call(*args)
  end

  def call(asset_data, legacy_url_path, new_attributes = {})
    attributes = find_asset_by(legacy_url_path)
    asset_deleted = attributes["deleted"]

    if asset_deleted
      raise AssetAlreadyDeleted.new(asset_data.id, legacy_url_path)
    end

    if (replacement_path = new_attributes.delete("replacement_legacy_url_path"))
      new_attributes["replacement_id"] = find_asset_by(replacement_path)["id"]
    end

    keys = new_attributes.keys

    raise AssetAttributesEmpty.new(asset_data.id, legacy_url_path) if new_attributes.empty?

    unless attributes.slice(*keys) == new_attributes.slice(*keys)
      asset_manager.update_asset(attributes["id"], new_attributes)
    end
  end
end
