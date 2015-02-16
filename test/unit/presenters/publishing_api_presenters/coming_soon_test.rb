require 'test_helper'

class PublishingApiPresenters::ComingSoonTest < ActiveSupport::TestCase

  test 'presents a valid "coming_soon" content item' do
    base_path         = '/some/path'
    locale            = 'en'
    publish_timestamp = 1.day.from_now

    expected_hash = {
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      locale: locale,
      update_type: 'major',
      details: { publish_time: publish_timestamp },
      routes: [ { path: base_path, type: 'exact' } ]
    }

    presenter = PublishingApiPresenters::ComingSoon.new(base_path, publish_timestamp, locale)

    assert_equal expected_hash, presenter.as_json
    assert_valid_against_schema(presenter.as_json, 'coming_soon')
  end
end
