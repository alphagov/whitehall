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

  def find_asset_by(legacy_url_path)
    path = legacy_url_path.sub(/^\//, "")
    attributes = asset_manager.whitehall_asset(path).to_hash
    url = attributes["id"]
    id = url[/\/assets\/(.*)/, 1]
    attributes.merge("id" => id, "url" => url)
  rescue GdsApi::HTTPNotFound
    raise AssetNotFound, legacy_url_path
  end

  def find_asset_by_id(asset_manager_id)
    asset_manager.asset(asset_manager_id).to_hash
  rescue GdsApi::HTTPNotFound
    raise AssetNotFound, asset_manager_id
  end
end
