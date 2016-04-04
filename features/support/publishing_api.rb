require 'gds_api/publishing_api_v2'
require_relative '../../test/support/policy_tagging_helpers'

def stub_publishing_api_v1_requests
  v1_url = Plek.current.find('publishing-api')
  stub_request(:any, %r{\A#{ v1_url }})
end

Before do
  GdsApi::PublishingApiV2.any_instance.stubs(:publish)
  GdsApi::PublishingApiV2.any_instance.stubs(:put_content)
  GdsApi::PublishingApiV2.any_instance.stubs(:patch_links)
  stub_publishing_api_policies
  stub_publishing_api_v1_requests
end

World(PolicyTaggingHelpers)
