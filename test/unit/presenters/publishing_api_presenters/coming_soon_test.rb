require 'test_helper'

class PublishingApiPresenters::ComingSoonTest < ActiveSupport::TestCase

  test 'presents a valid "coming_soon" content item' do
    locale            = 'en'
    publish_timestamp = 1.day.from_now
    edition           = create(:scheduled_case_study,
                                title: 'Case study title',
                                summary: 'The summary',
                                body: 'Some content',
                                scheduled_publication: publish_timestamp)

    expected_hash = {
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      locale: locale,
      update_type: 'major',
      details: { publish_time: publish_timestamp },
      routes: [ { path: '/government/case-studies/case-study-title', type: 'exact' } ]
    }

    presenter = PublishingApiPresenters::ComingSoon.new(edition, locale)

    assert_equal expected_hash, presenter.as_json
    assert_valid_against_schema(presenter.as_json, 'coming_soon')
  end
end
