require 'gds_api/publishing_api_v2'

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
end
