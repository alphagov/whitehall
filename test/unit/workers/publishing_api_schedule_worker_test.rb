require 'test_helper'

class PublishingApiScheduleWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test 'publishes a publish intent for the base path and publish time' do
    base_path    = '/base_path/for/content.fr'
    publish_time = 2.days.from_now

    expected_payload = {
      publish_time: publish_time,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      routes: [{ path: base_path, type: 'exact' }]
    }
    expected_request = stub_publishing_api_put_intent(base_path, expected_payload)

    PublishingApiScheduleWorker.new.perform(base_path, publish_time.as_json)

    assert_requested expected_request
  end
end
