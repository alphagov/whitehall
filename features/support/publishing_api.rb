require 'gds_api/publishing_api_v2'
require_relative '../../test/support/policy_tagging_helpers'

Before do
  GdsApi::PublishingApiV2.any_instance.stubs(:publish)
  GdsApi::PublishingApiV2.any_instance.stubs(:put_content)
  GdsApi::PublishingApiV2.any_instance.stubs(:patch_links)
  stub_publishing_api_policies
end

World(PolicyTaggingHelpers)
