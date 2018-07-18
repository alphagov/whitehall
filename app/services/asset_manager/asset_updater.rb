class AssetManager::AssetUpdater
  include AssetManager::ServiceHelper

  class AssetAlreadyDeleted < StandardError
    def initialize(attachment_data_id, legacy_url_path)
      super("Asset '#{legacy_url_path}' for Attachment Data #{attachment_data_id} expected not to be deleted in Asset Manager")
    end
  end

  def self.call(*args)
    new.call(*args)
  end

  def call(attachment_data, legacy_url_path, new_attributes = {})
    attributes = find_asset_by(legacy_url_path)
    asset_deleted = attributes['deleted']

    if asset_deleted && attachment_data.deleted?
      return
    elsif asset_deleted && !attachment_data.deleted?
      raise AssetAlreadyDeleted.new(attachment_data.id, legacy_url_path)
    end

    if (replacement_path = new_attributes.delete('replacement_legacy_url_path'))
      new_attributes['replacement_id'] = find_asset_by(replacement_path)['id']
    end

    keys = new_attributes.keys
    unless attributes.slice(*keys) == new_attributes.slice(*keys)
      asset_manager.update_asset(attributes['id'], new_attributes)
    end
  end
end
