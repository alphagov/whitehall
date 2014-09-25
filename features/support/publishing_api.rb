require 'gds_api/publishing_api'

Before do
  GdsApi::PublishingApi.any_instance.stubs(:put_content_item)
end
