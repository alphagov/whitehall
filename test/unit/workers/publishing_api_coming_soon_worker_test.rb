require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiComingSoonWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test 'publishes a "coming_soon" format to the Publishing API' do
    uuid = "a-uuid"
    SecureRandom.stubs(uuid: uuid)

    base_path    = '/government/case-studies/case-study-title.fr'
    publish_time = 2.days.from_now
    locale       = 'fr'
    edition      = create(:scheduled_case_study,
                           title: 'Case study title',
                           summary: 'The summary',
                           body: 'Some content',
                           scheduled_publication: publish_time)

    expected_payload = {
      base_path: base_path,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      description: 'Coming soon',
      need_ids: [],
      locale: locale,
      details: { publish_time: publish_time },
      routes: [ { path: base_path, type: 'exact' } ],
      redirects: [],
      public_updated_at: edition.updated_at,
    }

    expected_links = PublishingApiPresenters::ComingSoon.new(edition).links

    requests = [
      stub_publishing_api_put_content(uuid, expected_payload),
      stub_publishing_api_publish(uuid, { locale: "fr", update_type: "major" }),
      stub_publishing_api_patch_links(uuid, links: expected_links),
    ]

    PublishingApiComingSoonWorker.new.perform(edition.id, locale)

    assert_all_requested requests
  end
end
