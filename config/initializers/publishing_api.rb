require 'gds_api/publishing_api'
require 'gds_api/publishing_api_v2'

Whitehall.publishing_api_client = GdsApi::PublishingApi.new(
  Plek.find('publishing-api'),
  bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
)

Whitehall.publishing_api_v2_client = GdsApi::PublishingApiV2.new(
  Plek.find('publishing-api'),
  bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
)
