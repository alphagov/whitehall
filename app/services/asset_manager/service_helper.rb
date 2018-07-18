module AssetManager::ServiceHelper
  class AssetManagerAssetNotFound < StandardError
    def initialize(legacy_url_path)
      message = "Asset with legacy URL path #{legacy_url_path} is not on Asset Manager"
      super(message)
    end
  end

  def asset_manager
    Services.asset_manager
  end
  private :asset_manager

  def find_asset_by(legacy_url_path)
    path = legacy_url_path.sub(/^\//, '')
    attributes = asset_manager.whitehall_asset(path).to_hash
    url = attributes['id']
    id = url[/\/assets\/(.*)/, 1]
    attributes.merge('id' => id, 'url' => url)
  rescue GdsApi::HTTPNotFound
    raise AssetManagerAssetNotFound.new(legacy_url_path)
  end

  private :find_asset_by
end
