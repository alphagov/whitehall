require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiGoneWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  setup do
    @uuid = "a-uuid"
    SecureRandom.stubs(uuid: @uuid)
  end

  test "publishes a 'gone' item for the supplied base path" do
    base_path = '/government/this-never-existed-honest'

    payload = {
      content_id: @uuid,
      format: 'gone',
      publishing_app: 'whitehall',
      update_type: 'major',
      routes: [{path: base_path, type: 'exact'}],
    }

    requests = stub_publishing_api_put_content_links_and_publish(payload)

    PublishingApiGoneWorker.new.perform(base_path)

    requests.each { |request| assert_requested request }
  end
end
