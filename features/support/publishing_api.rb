require 'gds_api/publishing_api_v2'
require_relative '../../test/support/policy_tagging_helpers'

Before do
  publishing_api_v1_endpoint = File.join(
    Plek.find('publishing-api'),
    "publish-intent"
  )
  stub_request(:any, %r{\A#{publishing_api_v1_endpoint}})
  GdsApi::PublishingApiV2.any_instance.stubs(:publish)
  GdsApi::PublishingApiV2.any_instance.stubs(:put_content)
  GdsApi::PublishingApiV2.any_instance.stubs(:patch_links)
  GdsApi::PublishingApiV2.any_instance.stubs(:unpublish)
  stub_publishing_api_policies
end

World(PolicyTaggingHelpers)
