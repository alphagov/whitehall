require 'gds_api/publishing_api'

Whitehall.publishing_api_client = GdsApi::PublishingApi.new(
  Plek.find('publishing-api'),
  bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
)

require 'services'
