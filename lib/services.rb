require "gds_api/publishing_api"
require "gds_api/asset_manager"

module Services
  def self.publishing_api
    @publishing_api ||= publishing_api_client_with_timeout(20)
  end

  def self.publishing_api_with_low_timeout
    @publishing_api_with_low_timeout ||= publishing_api_client_with_timeout(1)
  end

  def self.asset_manager
    @asset_manager ||= GdsApi::AssetManager.new(
      Plek.find("asset-manager"),
      bearer_token: ENV.fetch("ASSET_MANAGER_BEARER_TOKEN", "12345678"),
      timeout: 60,
    )
  end

  def self.publishing_api_client_with_timeout(timeout)
    GdsApi::PublishingApi.new(
      Plek.find("publishing-api"),
      bearer_token: ENV.fetch("PUBLISHING_API_BEARER_TOKEN", "example"),
      timeout:,
    )
  end
end
