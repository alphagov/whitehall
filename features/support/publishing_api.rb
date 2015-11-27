require 'gds_api/publishing_api_v2'

Before do
  GdsApi::PublishingApiV2.any_instance.stubs(:publish)
  GdsApi::PublishingApiV2.any_instance.stubs(:put_content)
  GdsApi::PublishingApiV2.any_instance.stubs(:put_links)
end
