class AssetManager::CreateAssetResponse
  def initialize(gds_api_response)
    @response_attributes = gds_api_response.to_h
  end

  def asset_manager_id
    @response_attributes["id"][/\/assets\/(.*)/, 1]
  end

  def filename
    @response_attributes["name"]
  end
end
