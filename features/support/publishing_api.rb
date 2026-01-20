require "gds_api/publishing_api"
require "gds_api/test_helpers/publishing_api"
require_relative "mocha"

Before do
  publishing_api_v1_endpoint = File.join(
    Plek.find("publishing-api"),
    "publish-intent",
  )

  stub_request(:any, %r{\A#{publishing_api_v1_endpoint}})
  GdsApi::PublishingApi.any_instance.stubs(:discard_draft)
  GdsApi::PublishingApi.any_instance.stubs(:publish)
  GdsApi::PublishingApi.any_instance.stubs(:put_content)
  GdsApi::PublishingApi.any_instance.stubs(:patch_links)
  GdsApi::PublishingApi.any_instance.stubs(:unpublish)
  GdsApi::PublishingApi.any_instance.stubs(:get_events_for_content_id).returns([])
  stub_request(:get, %r{\A#{Plek.find('publishing-api')}/v2/links})
    .to_return(body: { links: {} }.to_json)
  stub_request(:get, %r{\A#{Plek.find('publishing-api')}/v2/expanded-links})
    .to_return(body: { expanded_links: {} }.to_json)
  # Prevent publishing API base path checks from interfering with tests
  Whitehall::PublishingApi.stubs(:check_first_draft_can_be_published_at_base_path!).returns(nil)
end

World(GdsApi::TestHelpers::PublishingApi)
