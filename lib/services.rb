require 'gds_api/publishing_api_v2'
require 'gds_api/asset_manager'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.find('publishing-api'),
      bearer_token: (ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'),
      timeout: 20,
    )
  end

  def self.publishing_api_with_low_timeout
    @publishing_api_with_low_timeout ||= begin
      publishing_api.dup.tap do |client|
        client.options[:timeout] = 1
      end
    end
  end

  def self.asset_manager
    @asset_manager ||= GdsApi::AssetManager.new(
      Plek.find("asset-manager"),
      bearer_token: ENV["ASSET_MANAGER_BEARER_TOKEN"] || '12345678',
    )
  end
end
