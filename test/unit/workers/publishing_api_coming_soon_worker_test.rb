require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiComingSoonWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2
  setup do
    @uuid = "a-uuid"
    SecureRandom.stubs(uuid: @uuid)
  end

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
      content_id: @uuid,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      locale: locale,
      update_type: 'major',
      details: { publish_time: publish_time },
      routes: [ { path: base_path, type: 'exact' } ],
      public_updated_at: edition.updated_at,
    }

    content_request = stub_publishing_api_put_content(@uuid, expected_payload)
    publish_request = stub_publishing_api_publish(@uuid, { update_type: { locale: "fr", update_type: "major" } })

    PublishingApiComingSoonWorker.new.perform(edition.id, locale)

    assert_requested content_request
    assert_requested publish_request
  end
end
