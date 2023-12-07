module AssetManager::ServiceHelper
  class AssetNotFound < StandardError
    def initialize(identifier)
      super("Asset '#{identifier}' is not in Asset Manager")
    end
  end

private

  def asset_manager
    Services.asset_manager
  end

  def find_asset_by_id(asset_manager_id)
    asset_manager.asset(asset_manager_id).to_hash
  rescue GdsApi::HTTPNotFound
    raise AssetNotFound, asset_manager_id
  end
end
