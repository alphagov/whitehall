require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class PublishingApiGoneWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  setup do
    @uuid = "a-uuid"
    SecureRandom.stubs(uuid: @uuid)
    @base_path = '/government/this-never-existed-honest'

    @content = {
      base_path: @base_path,
      format: 'gone',
      publishing_app: 'whitehall',
      routes: [{path: @base_path, type: 'exact'}],
    }
  end

  test "publishes a 'gone' item for the supplied base path" do
    requests = [
      stub_publishing_api_put_content(@uuid, @content),
      stub_publishing_api_patch_links(@uuid, links: {}),
      stub_publishing_api_publish(@uuid, update_type: 'major', locale: 'en')
    ]

    PublishingApiGoneWorker.new.perform(@base_path)

    assert_all_requested requests
  end

  test "saves a draft 'gone' item for the supplied base path if draft == true" do
    requests = [
      stub_publishing_api_put_content(@uuid, @content),
    ]

    PublishingApiGoneWorker.new.perform(@base_path, draft: true)

    assert_all_requested requests
  end
end
