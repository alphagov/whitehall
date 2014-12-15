require 'test_helper'

class PublishingApiPresenters::ComingSoonTest < ActiveSupport::TestCase

  def present(edition)
    PublishingApiPresenters::ComingSoon.new(edition).as_json
  end

  test 'coming_soon presentation includes the correct values' do
    sched_time = 1.day.from_now
    edition = create(:scheduled_case_study, scheduled_publication: sched_time)
    path = Whitehall.url_maker.public_document_path(edition)
    expected_hash = {
      base_path: path,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      locale: 'en',
      update_type: 'major',
      details: {
        publish_time: sched_time
      },
      routes: [
        {
          path: path,
          type: 'exact'
        }
      ]
    }
    presented_hash = present(edition)
    assert_equal expected_hash, presented_hash

    assert_valid_against_schema(presented_hash, 'coming_soon')
  end
end
