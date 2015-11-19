require 'test_helper'
require 'securerandom'

class PublishingApiPresenters::ComingSoonTest < ActiveSupport::TestCase
  setup do
    @locale = 'en'
    @publish_timestamp = 1.day.from_now
    @content_id = SecureRandom.uuid
    SecureRandom.stubs(uuid: @content_id)
    @edition = create(:scheduled_case_study,
                       title: 'Case study title',
                       summary: 'The summary',
                       body: 'Some content',
                       scheduled_publication: @publish_timestamp,
                     )
  end

  test 'presents a valid "coming_soon" content item' do
    expected_hash = {
      content_id: @content_id,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      locale: @locale,
      update_type: 'major',
      details: { publish_time: @publish_timestamp },
      routes: [ { path: '/government/case-studies/case-study-title', type: 'exact' } ],
      public_updated_at: @edition.updated_at,
    }

    presenter = PublishingApiPresenters::ComingSoon.new(@edition, @locale)

    assert_equal expected_hash, presenter.as_json
    assert_valid_against_schema(presenter.as_json, 'coming_soon')
  end

  test "includes content IDs" do
    presenter = PublishingApiPresenters::ComingSoon.new(@edition, @locale)

    coming_soon_content_id = presenter.as_json.fetch(:content_id)
    assert_equal @content_id, coming_soon_content_id
  end
end
