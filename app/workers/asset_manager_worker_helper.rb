module AssetManagerWorkerHelper
  def asset_manager
    Services.asset_manager
  end
  private :asset_manager

  def find_asset_by(legacy_url_path)
    attributes = asset_manager.whitehall_asset(legacy_url_path).to_hash
    url = attributes['id']
    id = url[/\/assets\/(.*)/, 1]
    attributes.merge('id' => id, 'url' => url)
  end
  private :find_asset_by
end
