require 'test_helper'

class PublishingApiComingSoonWorkerTest < ActiveSupport::TestCase
  test 'publishes a "coming_soon" format to the Publishing API' do
    base_path    = '/government/case-studies/case-study-title.fr'
    publish_time = 2.days.from_now
    locale       = 'fr'
    edition      = create(:scheduled_case_study,
                           title: 'Case study title',
                           summary: 'The summary',
                           body: 'Some content',
                           scheduled_publication: publish_time)

    expected_payload = {
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      locale: locale,
      update_type: 'major',
      details: { publish_time: publish_time },
      routes: [ { path: base_path, type: 'exact' } ]
    }

    expected_request = stub_publishing_api_put_item(base_path, expected_payload)

    PublishingApiComingSoonWorker.new.perform(edition, locale)

    assert_requested expected_request
  end
end
