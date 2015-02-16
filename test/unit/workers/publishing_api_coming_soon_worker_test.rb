require 'test_helper'

class PublishingApiComingSoonWorkerTest < ActiveSupport::TestCase
  test 'publishes a "coming_soon" format to the Publishing API' do
    base_path    = '/base_path/for/content.fr'
    publish_time = 2.days.from_now
    locale       = 'fr'

    expected_payload = {
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      locale: locale,
      update_type: 'major',
      details: { publish_time: publish_time },
      routes: [ { path: base_path, type: 'exact'} ]
    }
    expected_request = stub_publishing_api_put_item(base_path, expected_payload)

    PublishingApiComingSoonWorker.new.perform(base_path, publish_time.as_json, locale)

    assert_requested expected_request
  end
end
