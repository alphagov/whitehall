class AssetManagerUpdateAssetWorker
  include AssetManagerWorkerHelper

  class AssetManagerAssetDeleted < StandardError
    def initialize(attachment_data_id, legacy_url_path)
      message = "Asset corresponding to AttachmentData ID #{attachment_data_id} and legacy URL path #{legacy_url_path} expected not to be deleted in Asset Manager"
      super(message)
    end
  end

  def perform(attachment_data, legacy_url_path, new_attributes = {})
    attributes = find_asset_by(legacy_url_path)
    asset_deleted = attributes['deleted']

    if asset_deleted && attachment_data.deleted?
      return
    elsif asset_deleted && !attachment_data.deleted?
      raise AssetManagerAssetDeleted.new(attachment_data.id, legacy_url_path)
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
